FROM debian:8

ARG FZF_VERSION=0.18.0

ENV DOCKER_IMAGE="debian-8-fzf-${FZF_VERSION}"
ENV DOCKER_PACKAGES="wget bash-completion gradle git"

COPY etc/apt/debian-8.sources.list /etc/apt/sources.list

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes \
      ${DOCKER_PACKAGES}
RUN wget -P /src "https://github.com/junegunn/fzf-bin/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tgz" \
      && tar -C /usr/local/bin/ -xzf /src/fzf-${FZF_VERSION}-linux_amd64.tgz \
      && wget -O /usr/local/bin/fzf-tmux "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/bin/fzf-tmux" \
      && chmod +x /usr/local/bin/fzf-tmux
COPY root/debian.bashrc /root/.bashrc
