# Dotfiles

Personal dotfiles for shell and IDE configuration.

## Repository Structure

| File | Purpose |
|------|---------|
| `.zshrc` | Zsh shell configuration |
| `.zprofile` | Zsh profile configuration |
| `.gitconfig` | Git configuration |
| `.config/kaku/` | Kaku configuration framework |
| `settings.jar` | IntelliJ/JetBrains IDE settings export |

## Setup

1. Clone this repo: `git clone https://github.com/jingchaodev/.dotfiles ~/.dotfiles`
2. Symlink files:
   ```bash
   ln -sf ~/.dotfiles/.zshrc ~/.zshrc
   ln -sf ~/.dotfiles/.zprofile ~/.zprofile
   ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig
   mkdir -p ~/.config
   ln -sf ~/.dotfiles/.config/kaku ~/.config/kaku
   ```

## Notes
- Updated on April 27, 2026 to include latest zsh, git, and kaku configs.

## iTerm2 Setup
- Preferences are stored in `iterm2/com.googlecode.iterm2.plist`.
- To sync: Open iTerm2 → **Settings > General > Preferences** → Check **"Load preferences from a custom folder or URL"** → Select the `~/.dotfiles/iterm2` folder.
