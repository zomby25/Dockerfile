FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-terminal \
    firefox-esr \
    python3 \
    python3-pip \
    python3-venv \
    sudo \
    tigervnc-standalone-server \
    novnc \
    websockify \
    dbus-x11 \
    dbus \
    xterm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Utilisateur du bureau
RUN useradd -m -s /bin/bash rdpuser \
    && echo "rdpuser:ChangeMoi123!" | chpasswd \
    && usermod -aG sudo rdpuser \
    && echo "rdpuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/rdpuser \
    && chmod 440 /etc/sudoers.d/rdpuser

# Configuration XFCE
RUN mkdir -p /home/rdpuser/.vnc

RUN printf '%s\n' \
    '#!/bin/sh' \
    'unset SESSION_MANAGER' \
    'unset DBUS_SESSION_BUS_ADDRESS' \
    'export XDG_SESSION_TYPE=x11' \
    'export XDG_CURRENT_DESKTOP=XFCE' \
    'exec dbus-run-session -- startxfce4' \
    > /home/rdpuser/.vnc/xstartup

RUN chmod +x /home/rdpuser/.vnc/xstartup \
    && chown -R rdpuser:rdpuser /home/rdpuser

# Environnement Python
RUN python3 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# Playwright
RUN pip install --no-cache-dir playwright \
    && playwright install --with-deps chromium

EXPOSE 8080

CMD set -e; \
    echo "ChangeMoi123!" | vncpasswd -f > /home/rdpuser/.vnc/passwd; \
    chmod 600 /home/rdpuser/.vnc/passwd; \
    chown -R rdpuser:rdpuser /home/rdpuser/.vnc; \
    su - rdpuser -c "vncserver :1 -geometry 1280x720 -depth 24"; \
    websockify --web=/usr/share/novnc/ 0.0.0.0:${PORT:-8080} 127.0.0.1:5901
