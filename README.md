# 🔔 **chime** - terminal utility alarm

[![NixOS](https://img.shields.io/badge/NixOS-Compatible-blue.svg)](https://nixos.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)

<p align="center">
  <img src="https://github.com/SpitfireGG/chime/blob/main/assets/chime.png" alt="chime Terminal Timer Demo" width="800"/>
</p>

> A simple and lightweight terminal timer utility designed for productivity and focus

##  Features

- **Simple** — beautiful terminal interface with progress bars and color-coded information
- **Milestone notifications** — receive desktop notifications at milestones 25% - 75%
- **Write task** — Attach descriptions to your timers for better task management
- **audio alerts** — configurable alarm sounds when your timer completes
- **pause & resume** — easily control your timer with  keyboard shortcuts ( pause / resume )
- **session history** — manage and view your saved sessions
- **states** — save and restore timer states between any sessions

**NOTE:** The timer and resume functionality is not currently working.

## Installation

```bash
# Clone the repository
git clone https://github.com/SpitfireGG/chime.git 

# Make the script executable
chmod +x chime/chime.sh

# optional: create a symlink to your path
ln -s "$(pwd)/chime/chime.sh" ~/.local/bin/chime
```

## usage

```bash
chime -h 1 -m 30 -t "Deep work session"
```

### Command-line Options

| Option | Description                                |
|--------|--------------------------------------------|
| `-h`   | Hours                                      |
| `-m`   | Minutes                                    |
| `-s`   | Seconds                                    |
| `-t`   | Task description                           |
| `-f`   | Custom sound file path                     |
| `-e`   | Action to take after timer completes       |
| `-c`   | Load from configuration file               |
| `-r`   | Resume from saved state                    |
| `-l`   | List timer history                         |
| `-v`   | Display version                            |

### Keyboard Controls

| Shortcut | Action               |
|----------|-----------------------|
| Ctrl+Z   | Pause timer          |
| Ctrl+P   | Resume paused timer  |
| Ctrl+C   | Exit and save state  |


## ⚙️ Configuration

Create `~/.config/bash_alarm/config` with your preferred settings:

```bash
# manually select sound for timer completion in the .sh
default_ring="/path/to/your/favorite/sound.mp3"

# defauilt  message are displayed after timer completes
default_end="Time to stretch and hydrate!"
```

## You can use chime for:

- pomodoro technique sessions
- code sprint timers
- meeting reminders
- focus sessions
- break reminders

##  Under the Hood

chime is built using pure Bash. It leverages:

- ANSI color codes for beautiful terminal output
- desktop notification systems (notify-send)
- efficient time calculation algorithms
