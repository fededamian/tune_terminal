#!/bin/bash


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
  mkdir -p $HOME/repos

  # If powerlevel9k repository is present, do a pull. Otherwise, a clone.
  if [ -d "$HOME/repos/powerlevel9k" ]; then

    # Pull Powerlevel9k repo.
    git -C $HOME/repos/powerlevel9k pull

  else

    # Clone Powerlevel9k repo.
    git -C $HOME/repos/ clone https://github.com/bhilburn/powerlevel9k.git

  fi

  # Inform the user that his .zshrc file will be overwritten and ask for
  # confirmation.
  echo "WARNING: Do you want the .zshrc in your home directory to be replaced with"
  echo "         the repo´s version (Only 'yes' will be accepted to approve)?"

  # Request user input.
  echo ""
  read OPT_INSTALL_ZSHRC
  echo ""

  # Only if the user answers 'yes', the file will be replaced. 
  if [[ "$OPT_INSTALL_ZSHRC" == "yes" ]]; then
    
    # Copy the .zshrc file of the repo to the User´s Home directory.
    cp ./zshrc.example $HOME/.zshrc

  else  
  
    # Inform user the file was not copied and what to do if he changes his mind.
    echo "INFO: .zshrc file not copied. You can run this script again if you change your mind."

  fi
}

main()
{
  install_zsh_and_plugins

  set_zsh_as_default_shell

  install_fonts

  install_colorls

  configure_zsh
}

main
