FROM mcr.microsoft.com/devcontainers/typescript-node:0-14

ARG USERNAME=node

# Corporate proxy is... going to corporate proxy.
ENV NODE_TLS_REJECT_UNAUTHORIZED=0
# Help massage some prompts to not happen or accept defaults.
ENV DEBIAN_FRONTEND=noninteractive
# Browsers are pre-installed, they don't need to be installed.
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
  apt-get install -y sudo ca-certificates && \
  rm -rf /var/lib/apt/lists/* && \
  echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME &&\
  chmod 0440 /etc/sudoers.d/$USERNAME && \
  apt-get upgrade -y

# Install other deps
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3008,DL3015
RUN deps=$(su node -c "npx playwright install-deps --dry-run") && \
  rawCommand=${deps#'sudo -- sh -c \" apt-get update&& '} && \
  rawCommand=${rawCommand%'\"'} && \
  eval "$rawCommand" && \
  su node -c "npx playwright install" && \
  apt-get install -y curl && \
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt-get update && \
  apt-get install -y gh \
  yamllint \
  jq \
  shellcheck \
  direnv && \
  npm install -g @angular/cli@11 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  su node -c "ng config -g cli.warnings.versionMismatch false" && \
  su node -c "ng analytics off"
