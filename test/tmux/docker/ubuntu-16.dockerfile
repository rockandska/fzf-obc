FROM ubuntu:xenial-20201030

ENV DOCKER_PACKAGES="wget bash-completion git docker.io"
RUN apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes \
      ${DOCKER_PACKAGES}

ARG FZF_VERSION=0.18.0

RUN wget --no-check-certificate -P /src "https://github.com/junegunn/fzf-bin/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tgz" \
      && tar -C /usr/local/bin/ -xzf /src/fzf-${FZF_VERSION}-linux_amd64.tgz \
      && wget --no-check-certificate -O /usr/local/bin/fzf-tmux "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/bin/fzf-tmux" \
      && chmod +x /usr/local/bin/fzf-tmux

COPY root/debian.bashrc /root/.bashrc
