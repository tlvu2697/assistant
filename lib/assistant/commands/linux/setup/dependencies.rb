# frozen_string_literal: true

module Assistant
  module Commands
    module Linux
      module Setup
        class Dependencies < ::Assistant::Commands::Linux::Base
          desc 'Setup Linux dependencies'

          def call
            Assistant::Utils.request_sudo_permission!

            [
              zsh, oh_my_zsh, pure_theme, linux_dependencies,
              ruby_dependencies, python_dependencies,
              postgresql_dependencies, wireguard_dependencies,
              ibus, goods
            ].flatten.each do |command|
              Assistant::Executor.instance.sync(command)
            end
          end

          def zsh
            Assistant::Models::Commands.new(<<~BASH)
              sudo apt install -y zsh
              sudo chsh -s $(which zsh)
            BASH
          end

          def oh_my_zsh
            Assistant::Models::Commands.new(<<~BASH)
              sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
              git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
            BASH
          end

          def pure_theme
            Assistant::Models::Command.new(<<~BASH)
              git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
            BASH
          end

          def linux_dependencies
            Assistant::Models::Commands.new(<<~BASH)
              sudo apt install -y baobab bat build-essential curl exuberant-ctags fd-find font-manager fzf git gnome-tweaks imwheel mlocate ripgrep tmux xclip wget

              ln -s $(which fdfind) $HOME/.local/bin/fd
              ln -s $(which batcat) $HOME/.local/bin/bat
            BASH
          end

          def ruby_dependencies
            Assistant::Models::Command.new(<<~BASH)
              sudo apt install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev
            BASH
          end

          def python_dependencies
            Assistant::Models::Command.new(<<~BASH)
              sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
            BASH
          end

          def postgresql_dependencies
            Assistant::Models::Command.new(<<~BASH)
              sudo apt install -y libpq-dev
            BASH
          end

          def wireguard_dependencies
            Assistant::Models::Command.new(<<~BASH)
              sudo apt install -y openresolv
            BASH
          end

          def ibus
            Assistant::Models::Commands.new(<<~BASH)
              sudo add-apt-repository -y ppa:bamboo-engine/ibus-bamboo
              sudo apt-get update
              sudo apt-get install ibus-bamboo
              env DCONF_PROFILE=ibus dconf write /desktop/ibus/general/preload-engines "['BambooUs', 'Bamboo']"
              gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'Bamboo')]"
              ibus restart
            BASH
          end

          def goods
            Assistant::Models::Command.new(<<~BASH)
              sudo snap install beekeeper-studio mailspring notion-snap postman slack spotify telegram-desktop
            BASH
          end
        end
      end
    end
  end
end
