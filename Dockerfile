# FROM archlinux:latest
FROM ghcr.io/archlinux/archlinux:latest

# Update system and install base tools
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        base-devel \
        git \
        perl \
        wget \
        curl \
        python \
        otf-latin-modern \
        texlive-latex \
        texlive-latexbase \
        texlive-luatex \
        texlive-fontsextra \
        texlive-latexextra \
        texlive-binextra \
    && pacman -Scc --noconfirm

# Install yay (AUR helper) for AUR packages like otf-firamono-nerd
RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
WORKDIR /home/builder

RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm && \
    cd .. && rm -rf yay

# Install AUR package
RUN yay -S --noconfirm otf-firamono-nerd

USER root

# Clone and install depp (l3build package)
WORKDIR /opt
RUN git clone https://gitlab.com/islandoftex/texmf/depp.git && \
    cd depp && \
    l3build install

# Clone fancyqr
RUN git clone https://github.com/EagleoutIce/fancyqr.git

# Set up working directory for fancyqr with depp config
WORKDIR /opt/fancyqr
RUN cp /opt/depp/example/DEPP.rc .

# Default: compile qr-example.tex using DEPP.rc
CMD ["sh", "-c", "latexmk -r DEPP.rc qr-example.tex"]
