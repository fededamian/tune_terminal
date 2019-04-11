#!/bin/bash

# Global Variables.
readonly REPOS_FOLDER="$HOME/public-repos"
readonly NEEDED_COMMANDS="brew git"

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

install_zsh_and_plugins()
{
  echo "[*] INFO: Installing ZSH and its plugins."

  brew install zsh

  brew install zsh-syntax-highlighting

  brew install zsh-autosuggestions
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
  echo "[*] INFO: Installing hack nerd font."

  brew tap caskroom/fonts

  brew cask install font-hack-nerd-font
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
  cp ./dark_colors.yaml $HOME/.config/colorls/dark_colors.yaml
}

configure_zsh()
{
  # Make sure a directory for the repo exists.
  mkdir -p "$REPOS_FOLDER"

  # If powerlevel9k repository is present, do a pull. Otherwise, a clone.
  if [ -d "$REPOS_FOLDER/powerlevel9k" ]; then

    # Pull Powerlevel9k repo.
    git -C $REPOS_FOLDER/powerlevel9k pull

  else

    # Clone Powerlevel9k repo.
    git -C $REPOS_FOLDER clone https://github.com/bhilburn/powerlevel9k.git

  fi

  # Inform the user that his .zshrc file will be overwritten and ask for
  # confirmation.
  echo "WARNING: Do you want the .zshrc in your home directory to be replaced with"
  echo "         the repo´s version? Previous version will be stored as .bak."
  echo "         (Only 'yes' will be accepted to approve)?"

  # Request user input.
  echo ""
  read OPT_INSTALL_ZSHRC
  echo ""

  # Only if the user answers 'yes', the file will be replaced. 
  if [[ "$OPT_INSTALL_ZSHRC" == "yes" ]]; then
    
    # If there was a .zshrc file, it will be backed up.
    if [[ -f "$HOME/.zshrc" ]]; then

      # Move current .zshrc file to a backup file.
      mv "$HOME/.zshrc" "$HOME/.zshrc.bak" 

    fi

    # Copy the .zshrc file of the repo to the User´s Home directory.
    cp ./zshrc.example $HOME/.zshrc

  else  
  
    # Inform user the file was not copied and what to do if he changes his mind.
    echo "INFO: .zshrc file not copied. You can run this script again if you change your mind."

  fi
}

main()
{
  check_commands

  install_zsh_and_plugins

  set_zsh_as_default_shell

  install_fonts

  install_colorls

  configure_zsh
}

main
