---
description: Analyze macOS disk usage and suggest cleanup. Use when the user asks about disk space, storage, freeing space, or what's taking up room on their Mac.
---

# disk-cleanup

Identify what's consuming disk space on macOS and interactively clean safe-to-delete items.

## Steps

1. **Show overall disk state:**
   ```bash
   df -h /
   ```

2. **Scan the biggest consumers** in `~/Library` and hidden dotfiles:
   ```bash
   du -sh ~/Library/* 2>/dev/null | sort -hr | head -15
   du -sh ~/.* 2>/dev/null | sort -hr | head -15
   ```

3. **Check known space hogs** (only report those that exist and are >500 MB):

   | Target | Path | Clean command |
   |--------|------|---------------|
   | Docker virtual disk | `~/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw` | Quit Docker, delete the file |
   | iOS Simulators | `~/Library/Developer/CoreSimulator` | `xcrun simctl delete unavailable` or `xcrun simctl delete all` |
   | Xcode DerivedData | `~/Library/Developer/Xcode/DerivedData` | `rm -rf ~/Library/Developer/Xcode/DerivedData` |
   | Xcode Device Support | `~/Library/Developer/Xcode/iOS DeviceSupport` | `rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport` |
   | Android emulators | `~/.android/avd` | Delete individual AVDs |
   | Spotify cache | `~/Library/Caches/com.spotify.client` | Quit Spotify, delete folder |
   | uv cache | `~/.cache/uv` | `uv cache clean` |
   | pip cache | `~/Library/Caches/pip` | `pip cache purge` |
   | Homebrew | `~/Library/Caches/Homebrew` | `brew cleanup --prune=all` |
   | npm cache | `~/.npm` | `npm cache clean --force` |
   | Go build cache | `~/Library/Caches/go-build` | `go clean -cache` |
   | Gradle cache | `~/.gradle/caches` | `rm -rf ~/.gradle/caches` |
   | Ollama models | `~/.ollama` | `ollama rm <model>` |
   | Trash | Bin | Empty from Finder |

4. **Present a summary table** sorted by size with:
   - What it is
   - Size
   - Safe to delete? (cache vs data)
   - Cleanup command

5. **Ask the user** which items to clean before taking any action.

## Rules

- Never delete anything without explicit user confirmation.
- Warn if an app must be quit first (Docker, Spotify).
- Distinguish caches (regenerate automatically) from data (gone forever).
- After cleanup, run `du` or `df` again to confirm space freed.
- Note that macOS System Settings > Storage is slow to recalculate — the real proof is `df -h /`.

<example>
user: my mac is running out of space
assistant: [invokes disk-cleanup, scans, presents table, asks what to remove]
</example>

<example>
user: what's using all my disk space?
assistant: [invokes disk-cleanup, scans, presents findings]
</example>
