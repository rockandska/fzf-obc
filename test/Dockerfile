ARG BASH_VER

FROM alpine/git:v2.30.0 as bats
ARG BATS_VERSION
  RUN git clone --single-branch --branch "${BATS_VERSION}" \
    https://github.com/bats-core/bats-core.git /root/bats-core

FROM bash:${BASH_VER} as bash-completion
ARG BASH_VER
  RUN apk add --update git
  COPY download-completion.sh /tmp/download-completion.sh
  RUN chmod +x /tmp/download-completion.sh && /tmp/download-completion.sh \
    https://github.com/scop/bash-completion.git \
    "${BASH_VER}" \
    /root/bash-completion

FROM bash:${BASH_VER} as fzf
ARG FZF_VERSION
  RUN apk add --update tar
  RUN wget --no-check-certificate -P /tmp \
        "https://github.com/junegunn/fzf-bin/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tgz" \
      && tar -C /usr/local/bin/ -xzf /tmp/fzf-${FZF_VERSION}-linux_amd64.tgz \
      && wget --no-check-certificate -O /usr/local/bin/fzf-tmux \
        "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/bin/fzf-tmux" \
      && chmod +x /usr/local/bin/fzf \
      && chmod +x /usr/local/bin/fzf-tmux

FROM bash:${BASH_VER}
ARG GNU
ARG BASH_COMPLETION_SRC=/usr/local/src/bash-completion
ARG FZF_VERSION
  # Gnu tools
  RUN if [[ "${GNU:-}" == "True" ]];then \
    apk add sed coreutils findutils \
  ;fi
  # Bash completion deps
  RUN apk add --update --virtual completion-deps make automake autoconf
  # Bats deps
  RUN apk add parallel ncurses \
        && mkdir -p ~/.parallel \
        && touch ~/.parallel/will-cite
  # Tmux tests dependencies
  RUN apk add ncurses git git-bash-completion make tar
  # Bats install
  COPY --from=bats /root/bats-core /root/bats-core
  RUN /root/bats-core/install.sh "/usr/local"
  # bash completion install
  COPY --from=bash-completion /root/bash-completion ${BASH_COMPLETION_SRC}/
  RUN cd "${BASH_COMPLETION_SRC}" \
      && autoreconf -i \
      && ./configure --prefix= \
      && make \
      && make install
  # fzf installation
  COPY --from=fzf /usr/local/bin/fzf /usr/local/bin/fzf
  COPY --from=fzf /usr/local/bin/fzf-tmux /usr/local/bin/fzf-tmux
  # Clean
  RUN apk del completion-deps \
        && rm -rf "${BASH_COMPLETION_SRC}" \
        && rm -rf /var/cache/apk/*
  # Setup
  RUN echo 'source /etc/profile' >> ~/.bashrc
  WORKDIR /code/
  ENTRYPOINT ["bash"]
  CMD ["bash", "-c", "tail -f /dev/null"]
