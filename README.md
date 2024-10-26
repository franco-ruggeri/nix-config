# Dotfiles

## Install GNU Stow

On Arch Linux:

```bash
pacman -S stow
```

On macOS:

```bash
brew install stow
```

## Install dotfiles

Clone repository:

```bash
git clone git@github.com:franco-ruggeri/dotfiles.git ~/dotfiles
```

Install dotfiles:

```bash
cd ~/.dotfiles
stow --no-folding .
```
