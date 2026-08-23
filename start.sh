#!/bin/bash

set -e

export USER=rdpuser
export HOME=/home/rdpuser

mkdir -p "$HOME/.vnc"

cat > "$HOME/.vnc/xstartup" <<'EOF'
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

xrdb "$HOME/.Xresources" 2>/dev/null || true

startxfce4 &
EOF

chmod +x "$HOME/.vnc/xstartup"
chown -R rdpuser:rdpuser "$HOME/.vnc"

# Mot de passe VNC
echo "ChangeMoi123!" | vncpasswd -f > "$HOME/.vnc/passwd"
chmod 600 "$HOME/.vnc/passwd"
chown rdpuser:rdpuser "$HOME/.vnc/passwd"

# Démarrage du serveur VNC
su - rdpuser -c "vncserver :1 -geometry 1280x720 -depth 24"

# VNC : 5901
# noVNC : 8080
websockify --web=/usr/share/novnc/ 0.0.0.0:8080 localhost:5901
