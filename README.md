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
   Note the `HOMEBREW_NO_INSTALL_FROM_API=1` is to prevent [this](https://github.com/orgs/Homebrew/discussions/4231) problem

2. Start sleepwatcher
   ```
   brew services start sleepwatcher
   ```

3. Place `.sleep` and `.wakeup` into your home directory
   ```
   cp .sleep .wakeup ~/
   chmod +x ~/.sleep ~/.wakeup
   ```

6. Configure sudo permissions for the shutdown command:
   ```
   sudo visudo
   ```
   
   Add this line (replace `<username>` with your username):
   ```
   <username> ALL = NOPASSWD: /sbin/shutdown
   ```
7. Try it out! Since your lid angle sensor is probably damaged, closing your lid too fast may not trigger the sensor and no sleep will be done. So to make sure this script is executed normaly, **close your lid slowly** in a way that you can see the screen is turned off and on again.
You can play a music as a sleep status indicator. if succussful, you will observe:
- Your mac stopped playing music during lid closing
- it resumed playing music when lid is closed
- it stopped playing music again around 3 seconds later, this is triggered by this script

## Troubleshooting
The detection is simply done by last sleep duration. so if you find something strange like you waked up your mac but the script put it to sleep later, simply wait ~5 second before wake up your mac again.

For more problem,
1. Check logs in `~/.mac_sleep_fix/`
   - `sleep_wake.log`: Records all sleep and wake events with timestamps
   - `last_sleep_timestamp`: Contains the epoch time of the last sleep event
   - `last_wake_timestamp`: Contains the epoch time of the last wake event
2. Verify sleepwatcher is running: `ps aux | grep sleepwatcher`
3. Test scripts manually: `sh ~/scripts/sleep.sh` and `sh ~/scripts/wake.sh` 
