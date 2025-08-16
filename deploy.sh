#!/bin/bash

# Variables - change these to match your CLI binary
CLI_NAME="low-power-mac"
CLI_PATH="./build/$CLI_NAME/Build/Products/Release/$CLI_NAME"   # Path to your built binary
INSTALL_PATH="/usr/local/bin/$CLI_NAME"
PLIST_NAME="de.jleutgeb.$CLI_NAME.plist"
PLIST_PATH="/Library/LaunchDaemons/$PLIST_NAME"
LOG_PATH="/tmp/$CLI_NAME.log"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo"
   exit 1
fi

echo "Copying CLI to $INSTALL_PATH..."
cp "$CLI_PATH" "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"


echo "Creating LaunchDaemon plist at $PLIST_PATH..."
cat <<EOF > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_NAME</string>

    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_PATH</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>$LOG_PATH</string>

    <key>StandardErrorPath</key>
    <string>$LOG_PATH</string>
</dict>
</plist>
EOF

echo "Setting permissions for plist..."
chmod 644 "$PLIST_PATH"
chown root:wheel "$PLIST_PATH"

echo "Loading LaunchDaemon..."
launchctl load "$PLIST_PATH"

echo "✅ $CLI_NAME is now running in the background"