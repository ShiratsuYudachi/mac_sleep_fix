#!/bin/bash

# install.sh - Setup script for the Mac Sleep Fix
# This script will:
# 1. Check if sleepwatcher is installed, install if not
# 2. Copy the scripts to the user's home directory
# 3. Set up the LaunchAgent
# 4. Remind about sudo privileges for shutdown

echo "Setting up Mac Sleep Fix..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Please install Homebrew first:"
    echo "  /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Check if sleepwatcher is installed, install if not
if ! brew list sleepwatcher &> /dev/null; then
    echo "Installing sleepwatcher..."
    brew install sleepwatcher
else
    echo "sleepwatcher is already installed."
fi

# Create scripts directory
SCRIPTS_DIR="$HOME/scripts"
mkdir -p "$SCRIPTS_DIR"

# Copy scripts to the scripts directory
echo "Copying scripts to $SCRIPTS_DIR..."
cp "$SCRIPT_DIR/sleep.sh" "$SCRIPTS_DIR/"
cp "$SCRIPT_DIR/wake.sh" "$SCRIPTS_DIR/"
chmod +x "$SCRIPTS_DIR/sleep.sh" "$SCRIPTS_DIR/wake.sh"

# Create LaunchAgents directory
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$LAUNCH_AGENTS_DIR"

# Create the plist file
PLIST_FILE="$LAUNCH_AGENTS_DIR/de.bernhard-baehr.sleepwatcher.plist"
echo "Creating LaunchAgent plist file at $PLIST_FILE..."

cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>de.bernhard-baehr.sleepwatcher</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/sbin/sleepwatcher</string>
        <string>-V</string>
        <string>-s</string>
        <string>$SCRIPTS_DIR/sleep.sh</string>
        <string>-w</string>
        <string>$SCRIPTS_DIR/wake.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

# Load the LaunchAgent
echo "Loading LaunchAgent..."
launchctl unload "$PLIST_FILE" 2>/dev/null
launchctl load "$PLIST_FILE"

# Create log directory
LOG_DIR="$HOME/.mac_sleep_fix"
mkdir -p "$LOG_DIR"

# Remind about sudo permissions
echo ""
echo "IMPORTANT: To allow the script to trigger sleep automatically, you need to"
echo "configure sudo permissions for the shutdown command."
echo ""
echo "Run the following command to edit the sudoers file:"
echo "  sudo visudo"
echo ""
echo "Then add this line (replace $(whoami) with your username if different):"
echo "  $(whoami) ALL = NOPASSWD: /sbin/shutdown"
echo ""
echo "Installation completed!"
echo "The system will now detect and fix lid sensor issues automatically."
echo "Logs will be written to $LOG_DIR/sleep_wake.log" 