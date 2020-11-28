#!/bin/bash

$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh);

$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh);

brew install tmux neovim wget fzf node git gpg the_silver_searcher redis awscli;

brew cask install keepassxc;

$(brew --prefix)/opt/fzf/install --all;

wget https://raw.githubusercontent.com/idpbond/config/master/.tmux.conf > ~/.tmux.conf;

wget https://raw.githubusercontent.com/idpbond/config/master/nvim > ~/.config/;

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm;

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim';

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.1/install.sh | bash ;

# RVM
curl -sSL https://rvm.io/mpapis.asc | gpg --import - ;
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - ;
curl -sSL https://get.rvm.io | bash -s stable --ruby ;




# TODO BTT import if possible
# wget https://raw.githubusercontent.com/idpbond/config/master/bettertouchtools-Default.json

