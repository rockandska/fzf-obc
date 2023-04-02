FROM alpine/git:v2.30.0 as bats
ARG BATS_VERSION
  RUN git clone https://github.com/bats-core/bats-core.git /root/bats-core \
        && cd /root/bats-core \
        && git checkout "${BATS_VERSION}"

FROM alpine/git:v2.30.0 as bash-completion
ARG BASH_COMPLETION_VERSION=2.10
  RUN git clone https://github.com/scop/bash-completion.git /root/bash-completion \
        && cd /root/bash-completion \
        && git checkout "${BASH_COMPLETION_VERSION}"

FROM bash:4.4.23 as tini
  ENV TINI_VERSION v0.19.0
  RUN wget https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static -O /tini
  RUN chmod +x /tini

FROM bash:4.3.48
ARG GNU=false
ARG BASH_COMPLETION_SRC=/usr/local/src/bash-completion
ARG FZF_VERSION=0.18.0
  # Bash completion
  RUN apk add --update --virtual completion-deps make automake autoconf
  COPY --from=bash-completion /root/bash-completion ${BASH_COMPLETION_SRC}/
  RUN cd "${BASH_COMPLETION_SRC}" \
      && autoreconf -i \
      && ./configure --prefix= \
      && make \
      && make install
  # Bats
  RUN apk add --update parallel ncurses \
        && mkdir -p ~/.parallel \
        && touch ~/.parallel/will-cite
  COPY --from=bats /root/bats-core /root/bats-core
  RUN /root/bats-core/install.sh "/usr/local"
  # Gnu tools
  RUN if [[ "${GNU:-}" == true ]];then \
    apk add sed coreutils findutils \
  ;fi
  # Tmux tests dependencies
  RUN apk add ncurses git git-bash-completion make tar
  RUN wget --no-check-certificate -P /tmp \
        "https://github.com/junegunn/fzf-bin/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tgz" \
      && tar -C /usr/local/bin/ -xzf /tmp/fzf-${FZF_VERSION}-linux_amd64.tgz \
      && wget --no-check-certificate -O /usr/local/bin/fzf-tmux \
        "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/bin/fzf-tmux" \
      && chmod +x /usr/local/bin/fzf \
      && chmod +x /usr/local/bin/fzf-tmux
  # Clean
  RUN apk del completion-deps \
        && rm -rf "${BASH_COMPLETION_SRC}" \
        && rm -rf /var/cache/apk/*
  # Setup
  RUN echo 'source /etc/profile' >> ~/.bashrc
  COPY --from=tini /tini /tini
  WORKDIR /code/
  ENTRYPOINT ["/tini", "--"]
  CMD ["bash", "-c", "tail -f /dev/null"]
