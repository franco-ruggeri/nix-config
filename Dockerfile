FROM ubuntu:24.04

# Install Nix dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends -y curl xz-utils sudo ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Make /nix writable for user
RUN mkdir -m 0755 /nix && \
    chown ubuntu /nix

# Prepare user
USER ubuntu
ENV HOME=/home/ubuntu
WORKDIR $HOME

# Configure Nix
ENV NIX_CONF=$HOME/.config/nix/nix.conf
RUN mkdir -p "$(dirname $NIX_CONF)" && touch $NIX_CONF && \
  echo 'filter-syscalls = false' >> $NIX_CONF && \
  echo 'experimental-features = nix-command flakes' >> $NIX_CONF

# Install Nix
RUN curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install > install.sh && \
    sh install.sh --no-daemon --yes && \
    rm install.sh

# Install home-manager configuration
COPY --chown=ubuntu:ubuntu . $HOME/nix-config
ENV PATH="/home/ubuntu/.nix-profile/bin:$PATH"
ENV USER=ubuntu
RUN nix run github:nix-community/home-manager -- switch --flake "$HOME/nix-config#container-x86"

# Set login shell
USER root
RUN chsh --shell $HOME/.nix-profile/bin/zsh ubuntu
USER ubuntu

CMD [ "tail", "-f", "/dev/null" ]
