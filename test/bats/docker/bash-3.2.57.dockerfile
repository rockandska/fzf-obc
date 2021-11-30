FROM alpine/git:v2.30.0 as bats
ARG BATS_VERSION
  RUN git clone https://github.com/bats-core/bats-core.git /root/bats-core \
        && cd /root/bats-core \
        && git checkout "${BATS_VERSION}"

FROM alpine/git:v2.30.0 as bash-completion
ARG BASH_COMPLETION_VERSION=1.3
  RUN git clone https://github.com/scop/bash-completion.git /root/bash-completion \
        && cd /root/bash-completion \
        && git checkout "${BASH_COMPLETION_VERSION}"

FROM bash:3.2.57 as tini
  ENV TINI_VERSION v0.19.0
  RUN wget https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static -O /tini
  RUN chmod +x /tini

FROM bash:3.2.57
ARG GNU=false
ARG BASH_COMPLETION_SRC=/usr/local/src/bash-completion
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
  # Clean
  RUN apk del completion-deps \
        && rm -rf "${BASH_COMPLETION_SRC}" \
        && rm -rf /var/cache/apk/*
  # Setup
  RUN echo 'source /etc/profile' >> ~/.bashrc
  COPY --from=tini /tini /tini
  WORKDIR /code/
  ENTRYPOINT ["/tini", "--", "bash", "bats"]
