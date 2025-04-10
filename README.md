# Mac Sleep Fix

This tool helps fix the MacBook lid sensor issue where the laptop wakes up immediately after sleep when closing the lid.

## Background

This tool addresses a specific issue where a faulty lid angle sensor causes the MacBook to:
1. Go to sleep when the lid is partially closed
2. Wake up when the lid is closed further
3. Resulting in battery drain when the laptop is in a bag or closed

## How It Works

Two scripts work together with `sleepwatcher` to detect and fix this issue:

- `sleep.sh`: Records when the system goes to sleep
- `wake.sh`: Checks if the system woke up too soon after sleeping (within 3 seconds)
  - If a quick wake is detected, it triggers a forced sleep using `sudo shutdown -s now`

## Setup Instructions

1. Install sleepwatcher via Homebrew:
   ```
   HOMEBREW_NO_INSTALL_FROM_API=1 brew install sleepwatcher
   ```

2. Place these scripts in a location of your choice (e.g., `~/scripts/`):
   ```
   mkdir -p ~/scripts
   cp sleep.sh wake.sh ~/scripts/
   chmod +x ~/scripts/sleep.sh ~/scripts/wake.sh
   ```

3. Configure sleepwatcher to use these scripts:
   ```
   mkdir -p ~/Library/LaunchAgents
   ```

4. Create the sleepwatcher plist file:
   ```
   nano ~/Library/LaunchAgents/de.bernhard-baehr.sleepwatcher.plist
   ```

   Add this content (modify the paths as needed):
   ```xml
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
           <string>~/scripts/sleep.sh</string>
           <string>-w</string>
           <string>~/scripts/wake.sh</string>
       </array>
       <key>RunAtLoad</key>
       <true/>
       <key>KeepAlive</key>
       <true/>
   </dict>
   </plist>
   ```

5. Load the launch agent:
   ```
   launchctl load ~/Library/LaunchAgents/de.bernhard-baehr.sleepwatcher.plist
   ```

6. Configure sudo permissions for the shutdown command:
   ```
   sudo visudo
   ```
   
   Add this line (replace `<username>` with your username):
   ```
   <username> ALL = NOPASSWD: /sbin/shutdown
   ```

## Logs

The scripts create logs in `~/.mac_sleep_fix/`:
- `sleep_wake.log`: Records all sleep and wake events with timestamps
- `last_sleep_timestamp`: Contains the epoch time of the last sleep event
- `last_wake_timestamp`: Contains the epoch time of the last wake event

## Troubleshooting

If the scripts aren't working:

1. Check logs in `~/.mac_sleep_fix/sleep_wake.log`
2. Verify sleepwatcher is running: `ps aux | grep sleepwatcher`
3. Test scripts manually: `sh ~/scripts/sleep.sh` and `sh ~/scripts/wake.sh` 