FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-terminal \
    xrdp \
    dbus-x11 \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Création de l'utilisateur RDP
RUN useradd -m -s /bin/bash rdpuser \
    && echo 'rdpuser:ChangeMoi123!' | chpasswd \
    && usermod -aG sudo rdpuser

# XFCE comme bureau
RUN echo "startxfce4" > /home/rdpuser/.xsession \
    && chown rdpuser:rdpuser /home/rdpuser/.xsession

# XRDP écoute sur 3389
EXPOSE 3389

CMD service dbus start && service xrdp start && tail -f /dev/null
