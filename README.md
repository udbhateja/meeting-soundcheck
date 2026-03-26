# meeting-soundcheck

Play a custom entrance sound before your Microsoft Teams meetings — like a news anchor intro or a wrestler's walk-up music.

Inspired by the viral trend of playing BBC News / AajTak theme music before meetings.

## Demo

https://github.com/udbhateja/meeting-soundcheck/raw/master/assets/demo.mp4

## Requirements

- macOS (uses native calendar integration)
- [Homebrew](https://brew.sh) (for installing icalBuddy)
- Calendar synced with Microsoft Teams/Outlook via **System Settings > Internet Accounts**

## Quick Start

```bash
# Clone the repo
git clone https://github.com/udbhateja/meeting-soundcheck.git
cd meeting-soundcheck

# Install (checks dependencies + optional auto-start)
./install.sh

# Drop your sound file
cp ~/Downloads/your-theme-song.mp3 sounds/

# Run
./meeting_soundcheck.sh
```

## Configuration

Edit `config.sh` — it's the only file you need to touch:

| Setting | Default | Description |
|---------|---------|-------------|
| `LEAD_TIME_SECONDS` | `15` | Seconds before meeting to play sound |
| `CHECK_INTERVAL` | `10` | How often to check calendar (seconds) |
| `SOUND_FILE` | `""` | Path to sound file (auto-detects from `sounds/` if empty) |
| `TEAMS_ONLY` | `true` | Only trigger for Teams meetings |

## Sound File

Drop any `.mp3`, `.aiff`, `.wav`, or `.m4a` file into the `sounds/` folder. The script auto-picks it up — no config change needed.

Popular choices:
- BBC News theme
- AajTak news theme
- WWE entrance music
- The Office theme
- Your own custom walk-up song

## Auto-Start on Login

The installer asks if you want auto-start. To manage it manually:

```bash
# Enable
launchctl load ~/Library/LaunchAgents/com.meeting-soundcheck.plist

# Disable
launchctl unload ~/Library/LaunchAgents/com.meeting-soundcheck.plist

# View logs
tail -f /tmp/meeting-soundcheck.log
```

## Uninstall

```bash
./uninstall.sh
```

Stops the service and cleans up. Your config and sounds are preserved — delete the folder manually for full removal.

## How It Works

1. Reads your macOS Calendar (synced with Teams/Outlook) using [icalBuddy](https://hasseg.org/icalBuddy/)
2. Finds the next upcoming meeting
3. Checks if it has a Teams join link
4. Plays your sound file X seconds before the meeting starts
5. Repeats

## Roadmap

- [ ] Native macOS menu bar app (.dmg) for non-technical users
- [ ] Support for Google Meet and Zoom meetings
- [ ] Random sound selection from multiple files
- [ ] macOS notification alongside sound

## Contributing

PRs welcome! If you have ideas or improvements, open an issue or submit a PR.

## License

MIT
