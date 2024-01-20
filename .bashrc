# source /usr/local/lib/config/Bash_Profile

update_dotfiles() {
  local repo_dir="$HOME/.dotfiles"
  local repo_url="https://github.com/0mega24/se-dotfiles.git"

  local DOTFILES_BASHRC="$repo_dir/.bashrc"
  local HOME_BASHRC="$HOME/.bashrc"

  local DOTFILES_VIMRC="$repo_dir/.vimrc"
  local HOME_VIMRC="$HOME/.vimrc"

  if [ ! -d "$repo_dir" ]; then
    git clone "$repo_url" "$repo_dir"
  else
    (cd "$repo_dir" && git pull origin main)
  fi

  # backup bashrc if it exists
  if [ -f "$HOME_BASHRC" ] && [ ! -L "$HOME_BASHRC" ]; then
    mv "$HOME_BASHRC" "${HOME_BASHRC}.bak"
  fi

  if [ ! -L "$HOME_BASHRC" ]; then
    if [ -f "$DOTFILES_BASHRC" ]; then
      ln -s "$DOTFILES_BASHRC" "$HOME_BASHRC"
    else
      echo "dotfiles .bashrc not found. Symlink not created."
    fi
  fi

  # backup vimrc if it exists
  if [ -f "$HOME_VIMRC" ] && [ ! -L "$HOME_VIMRC" ]; then
    mv "$HOME_VIMRC" "$HOME_VIMRC.bak"
  fi

  if [ ! -L "$HOME_VIMRC" ]; then
    if [ -f "$DOTFILES_VIMRC" ]; then
      ln -s "$DOTFILES_VIMRC" "$HOME_VIMRC"
    else
      echo "dotfiles .vimrc not found. Symlink not created."
    fi
  fi
}

get_tools() {
  local tmux_url="https://github.com/nelsonenzo/tmux-appimage/releases/download/3.3a/tmux.appimage"
  local neovim_url="https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage"
  local fastfetch_url="https://github.com/fastfetch-cli/fastfetch/releases/download/2.6.0/fastfetch-2.6.0-Linux.zip"
  local btop_url="https://github.com/aristocratos/btop/releases/download/v1.3.0/btop-x86_64-linux-musl.tbz"
  
  local tools_dir="$HOME/.tools"

  mkdir -p "$tools_dir"

  if [ ! -f "$tools_dir/tmux" ]; then
    echo "Downloading tmux..."

    wget -O "$tools_dir/tmux" "$tmux_url" || curl -L "$tmux_url" -o "$tools_dir/tmux"

    chmod +x "$tools_dir/tmux"

    echo "Done setting up tmux"
  fi

  if [ ! -f "$tools_dir/neovim" ]; then
    echo "Downloading neovim..."

    wget -O "$tools_dir/neovim" "$neovim_url" || curl -L "$neovim_url" -o "$tools_dir/neovim"

    chmod +x "$tools_dir/neovim"

    echo "Done setting up neovim"
  fi

  if [ ! -f "$tools_dir/fastfetch" ]; then
    echo "Downloading fastfetch..."
	
    wget -O fastfetch.zip "$fastfetch_url" || curl -L "$fastfetch_url" -o fastfetch.zip
    unzip fastfetch.zip
    rm fastfetch.zip

    mv "./fastfetch-2.6.0-Linux/usr/bin/fastfetch" "$tools_dir/fastfetch"
    rm -rf "fastfetch-2.6.0-Linux"

    echo "Done setting up fastfetch"
  fi

  if [ ! -f "$tools_dir/btop" ]; then
    echo "Downloading btop..."
    
    wget -O btop.tbz "$btop_url" || curl -L "$btop_url" -o btop.tbz
    tar -xjf btop.tbz
    rm btop.tbz

    mv "./btop/bin/btop" "$tools_dir/btop"
    rm -rf "btop"

    echo "done setting up btop"
  fi

  # Add tools directory to PATH if not already present
  if [[ ":$PATH:" != *":$tools_dir:"* ]]; then
    echo "export PATH=\$PATH:$tools_dir" >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
  fi
}

update_tools() {
  rm -rf "$HOME/.tools"
  get_tools
}

tmux() {
  tmux.appimage
}

neovim() {
  nvim.appimage
}

extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <path/filename>"
    return 1
  fi
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf    "$1"  ;;
      *.tar.gz)    tar xzf    "$1"  ;;
      *.bz2)       bunzip2    "$1"  ;;
      *.rar)       unrar x    "$1"  ;;
      *.gz)        gunzip     "$1"  ;;
      *.tar)       tar xf     "$1"  ;;
      *.tbz2)      tar xjf    "$1"  ;;
      *.tgz)       tar xzf    "$1"  ;;
      *.zip)       unzip      "$1"  ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x       "$1"  ;;
      *)           echo       "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

userlist() {
  local option=${1:-all}
  local online_users=$(who | cut -d' ' -f1 | sort | uniq)
  local all_users=$(awk -F':' '{print $1}' /etc/passwd)

  case "$option" in
    online)
      echo -e "Online Users:"
      for user in $online_users; do
        echo -e "\e[32m$user\e[0m"
      done
      ;;
    offline)
      echo -e "Offline Users:"
        for user in $all_users; do
          if ! [[ $online_users =~ $user ]]; then
            echo -e "\e[31m$user\e[0m"
          fi
        done
        ;;
  esac
}

server_info() {
  local online_users=$(who | cut -d' ' -f1 | sort | uniq)
  local online_user_count=$(echo "$online_users" | wc -l)
  local current_user=$(whoami)

  echo -e "Welcome to RIT Servers!"
  echo -e "Current time is: $(date)"

  if [ "$online_user_count" -eq 1 ] && [[ $online_users == *"$current_user"* ]]; then
    echo -e "There is 1 user\e[32m online\e[0m - You!"
  else
    echo -e "There are $online_user_count user(s)\e[32m online\e[0m!"
  fi
}

cl() {
  clear
  fastfetch
}

install() {
  update_dotfiles
  get_tools
}

start() {
  update_dotfiles
  tmux
  cl
  server_info
}

start