#!/bin/bash

# Global Variables.
readonly NEEDED_COMMANDS="brew git"

get_path()
{
  # Save working directory.
  WORKDIR="$(pwd)"

  # The target file is the first argument of this function.
  TARGET_FILE=$1

  # Change to the target file directory.
  cd "$(dirname $TARGET_FILE)"

  # Get target file basename.
  TARGET_FILE="$(basename $TARGET_FILE)"

  # Iterate down a (possible) chain of symlinks.
  while [ -L "$TARGET_FILE" ]; do

    # Repeat previous process until the file is not a symlink anymore.
    TARGET_FILE="$(readlink $TARGET_FILE)"
    cd "$(dirname $TARGET_FILE)"
    TARGET_FILE="$(basename $TARGET_FILE)"

  done

  # Compute the canonicalized name by finding the physical path
  # for the directory we're in and appending the target file.
  PHYS_DIR="$(pwd -P)"

  # Print the physical directory as output.
  echo $PHYS_DIR

  # Go back to working directory.
  cd "$WORKDIR"
}

set_project_folder()
{
  # Use get_path to set the project folder variable.
  export PROJECT_FOLDER="$(get_path $0)"
}

check_commands()
{
  # Create a counter of missing commands.
  local MISSING_COUNTER=0

  # Iterate through all of the needed commands provided in the global variable.
  for NEEDED_COMMAND in $NEEDED_COMMANDS; do

    # Verify if command exists.
    if ! hash "$NEEDED_COMMAND" >/dev/null 2>&1; then

      # Inform user the command was not found and increase the counter of
      # missing commands.
      printf "Command not found in PATH: %s\n" "$NEEDED_COMMAND" >&2

      # Increase counter.
      ((MISSING_COUNTER++))

    fi

    done

    # If any of the commands is missing, the script finishes with an error code.
    if ((MISSING_COUNTER > 0)); then

      # Error Message.
      printf "Minimum %d commands are missing in PATH, aborting\n" "$MISSING_COUNTER" >&2

      # Exit with error.
      exit 1

    fi
}

install_oh_my_zsh_and_plugins()
{
  echo "[*] INFO: Installing Oh my Zsh and its plugins."

  # Oh my Zsh
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  # Sintax Highlighting Plugin
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

  # Perdictor Plugin
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

  # Powerlevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
}

set_zsh_as_default_shell()
{
  echo "[*] INFO: Setting ZSH as the default shell."

  # If the default shell is not set to ZSH, change it.
  if [[ "$SHELL" != "/bin/zsh" ]]; then

    # Change the default shell to ZSH.
    chsh -s /bin/zsh

  fi
}

install_fonts()
{
  echo "[*] INFO: Installing Hack Nerd and Meslo LG fonts."

  brew install --cask font-hack-nerd-font
  brew install --cask font-meslo-lg
}

install_colorls()
{

  # Attempt to get Ruby version.
  RUBY_VERSION="$(ruby --version)"

  # If Ruby is not present, install it. Otherwise, update it.
  if [[ "$?" -ne 0 ]]; then

    echo "[*] INFO: Installing Ruby."

    # Install ruby.
    brew update && brew install ruby

  else

    echo "[*] INFO: Updating Ruby."

    # Update ruby.
    brew update && brew upgrade ruby

  fi

  # Install colorls with gem.
  sudo gem install colorls

  # Create folder for color scheme.
  mkdir -p $HOME/.config/colorls

  # Configure color scheme.
  cp "$PROJECT_FOLDER/dark_colors.yaml" "$HOME/.config/colorls/dark_colors.yaml"
}

configure_zsh()
{
  # Inform the user that his .zshrc and .p10k.zsh files will be overwritten and ask for
  # confirmation.
  echo "WARNING: Do you want the .zshrc and .p10k.sh files in your home directory to"
  echo "         be replaced with the repo´s version? Previous versions will be stored as .bak."
  echo "         (Only 'yes' will be accepted to approve)?"

  # Request user input.
  echo ""
  read OPT_INSTALL_ZSHRC
  echo ""

  # Only if the user answers 'yes', the file will be replaced.
  if [[ "$OPT_INSTALL_ZSHRC" == "yes" ]]; then

    # Make Backups.
    [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
    [ -f "$HOME/.p10k.sh" ] && cp "$HOME/.p10k.sh" "$HOME/.p10k.sh.bak"

    # Copy the .zshrc file of the repo to the User´s Home directory.
    cp "$PROJECT_FOLDER/zshrc.example" "$HOME/.zshrc"
    cp "$PROJECT_FOLDER/p10k.example" "$HOME/.p10k.zsh"

  else

    # Inform user the file was not copied and what to do if he changes his mind.
    echo "INFO: .zshrc file not copied. You can run this script again if you change your mind."

  fi
}

main()
{
  set_project_folder

  check_commands

  install_oh_my_zsh_and_plugins

  set_zsh_as_default_shell

  install_fonts

  install_colorls

  configure_zsh
}

main
