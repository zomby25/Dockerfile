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

RUN useradd -m -s /bin/bash rdpuser \
    && echo 'rdpuser:ChangeMoi123!' | chpasswd \
    && adduser rdpuser sudo

RUN echo "startxfce4" > /home/rdpuser/.xsession \
    && chown rdpuser:rdpuser /home/rdpuser/.xsession

RUN sed -i 's/^port=3389/port=8080/' /etc/xrdp/xrdp.ini

EXPOSE 8080

CMD service dbus start && service xrdp start && tail -f /dev/null
