#!/bin/bash

$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh);
$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh);

sed -i'' 's/^plugins=(.*/plugins=(git fzf dotenv docker docker-compose)/' ~/.zshrc

brew install \
	alacritty \
	awscli \
	coreutils \
	deno \
	docker \
	docker-compose \
	ffmpeg \
	fzf \
	gifski \
	git \
	gpg \
	htop \
	hub \
	neovim \
	node \
	pyenv \
	rclone \
	redis \
	shared-mime-info \
	the_silver_searcher \
	tig \
	tmux \
	youtube-dl \
	wget;

brew install --cask \
	authy \
	barrier \
	bettertouchtool \
	google-backup-and-sync \
	keepassxc \
	keybase \
	notable \
	pg-commander \
	postgres \
	signal;

echo "Remember to:
	◘ set up Google Back Up and Sync in order to use keepass database
	◘ create a new AWS credential (or import one)
	◘ configure a postgres.app server with appropriate version for NEXT
	◘ Import BTT License (email) and settings from https://raw.githubusercontent.com/idpbond/config/master/bettertouchtools-Default.json
	◘ create a new token and add it to ~/.config/hub -- https://github.com/settings/tokens [repo.*, workflow, *:packages]
"

$(brew --prefix)/opt/fzf/install --all;

mkdir -p ~/.config;
git clone https://github.com/idpbond/config /tmp/config;
wget https://raw.githubusercontent.com/idpbond/config/master/.tmux.conf ~/.tmux.conf;
cp -r /tmp/config/nvim ~/.config/;
cp -r /tmp/config/alacritty ~/.config/;

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm;

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim';

nvim +PlugInstall +qall && \
nvim +'CocInstall -sync coc-prettier coc-neosnippet coc-git coc-eslint coc-tsserver coc-solargraph coc-json coc-angular coc-sh coc-deno' +qall ;

# Fonts (TODO: Automate)
# TODO: https://github.com/mdschweda/dejavusansmonocode
git clone https://github.com/tonsky/FiraCode /tmp/FiraCode;
cp /tmp/FiraCode/distr/ttf/*.ttf ~/Library/Fonts/;

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.1/install.sh | bash ;
echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> ~/.zshrc

# RVM
curl -sSL https://rvm.io/mpapis.asc | gpg --import - ;
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - ;
curl -sSL https://get.rvm.io | bash -s stable --ruby ;

cat ./zsh.partial >> ~/.zshrc

# TODO BTT import if possible
# wget https://raw.githubusercontent.com/idpbond/config/master/bettertouchtools-Default.json

npm install -g livereloadx
