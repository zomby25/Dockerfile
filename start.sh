#!/bin/bash

set -e

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

# Mot de passe VNC
echo "ChangeMoi123!" | vncpasswd -f > "$HOME/.vnc/passwd"

chmod 600 "$HOME/.vnc/passwd"
chown -R rdpuser:rdpuser "$HOME/.vnc"

# Démarrer VNC
su - rdpuser -c "vncserver :1 -geometry 1280x720 -depth 24"

# Railway fournit automatiquement PORT
PORT="${PORT:-8080}"

echo "Starting noVNC on port $PORT"

# noVNC/WebSocket
websockify \
  --web=/usr/share/novnc/ \
  "0.0.0.0:$PORT" \
  "127.0.0.1:5901"
