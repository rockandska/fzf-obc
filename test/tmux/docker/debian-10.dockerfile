FROM debian:10.2

COPY etc/apt /etc/apt

ENV DOCKER_PACKAGES="ca-certificates wget bash-completion git docker.io make"

RUN apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes \
      ${DOCKER_PACKAGES} \
      && rm -rf /var/lib/apt/lists/*

ARG FZF_VERSION=0.18.0

RUN wget -P /src "https://github.com/junegunn/fzf-bin/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tgz" \
      && tar -C /usr/local/bin/ -xzf /src/fzf-${FZF_VERSION}-linux_amd64.tgz \
      && wget -O /usr/local/bin/fzf-tmux "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/bin/fzf-tmux" \
      && chmod +x /usr/local/bin/fzf-tmux
