FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-terminal \
    tigervnc-standalone-server \
    novnc \
    websockify \
    dbus-x11 \
    xterm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash rdpuser \
    && mkdir -p /home/rdpuser/.vnc \
    && chown -R rdpuser:rdpuser /home/rdpuser

RUN printf '%s\n' \
    '#!/bin/sh' \
    'unset SESSION_MANAGER' \
    'unset DBUS_SESSION_BUS_ADDRESS' \
    'startxfce4 &' \
    > /home/rdpuser/.vnc/xstartup \
    && chmod +x /home/rdpuser/.vnc/xstartup \
    && chown rdpuser:rdpuser /home/rdpuser/.vnc/xstartup

EXPOSE 8080

CMD mkdir -p /home/rdpuser/.vnc && \
    echo "ChangeMoi123!" | vncpasswd -f > /home/rdpuser/.vnc/passwd && \
    chmod 600 /home/rdpuser/.vnc/passwd && \
    chown -R rdpuser:rdpuser /home/rdpuser/.vnc && \
    su - rdpuser -c "vncserver :1 -geometry 1280x720 -depth 24" && \
    websockify --web=/usr/share/novnc/ 0.0.0.0:${PORT:-8080} 127.0.0.1:5901
