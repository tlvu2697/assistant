# frozen_string_literal: true

module Assistant
  module Commands
    module Linux
      module Setup
        class Dev < Dry::CLI::Command
          desc 'Setup DevTools'

          NODEJS_VERSION = '16.17.1'
          RUBY_VERSION = '3.1.2'
          PYTHON3_VERSION = '3.10.5'

          def call(**); end

          def setup_gitignore_global
            Assistant::Models::Command.new(<<~BASH)
              echo "[*] Setting up gitignore_global..."
              git config --global core.excludesfile ~/.gitignore_global
            BASH
          end

          def install_dev_tools
            Assistant::Models::Command.new(<<~BASH)
              echo "[*] Installing alacritty, gh, neovim..."
              sudo add-apt-repository -y ppa:aslatter/ppa
              sudo apt update
              sudo apt install -y alacritty gh neovim
              git clone https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

            BASH
          end

          def install_asdf(nodejs_version, python3_version, ruby_version)
            Assistant::Models::Command.new(<<~BASH)
              echo "[*] Installing ASDF..."
              git clone https://github.com/asdf-vm/asdf.git ~/.asdf
              asdf plugin-add nodejs
              asdf plugin-add python
              asdf plugin-add ruby

              asdf install nodejs #{nodejs_version}
              asdf install python #{python3_version}
              asdf install ruby #{ruby_version}

              asdf global nodejs #{nodejs_version}
              asdf global python #{python3_version}
              asdf global ruby #{ruby_version}

              sudo ln -s ~/.asdf/shims/python3 /usr/local/bin/_python3
              pip3 install neovim
              npm install -g neovim
              gem install neovim
              gem install tmuxinator

              sudo ln -s ~/.asdf/installs/ruby/#{ruby_version}/bin/tmuxinator ~/.local/bin/muxinator
            BASH
          end

          def install_lazy_git
          end

          def install_lazy_docker
          end

          def install_overmind
          end

          def install_redis

          end
        end
      end
    end
  end
end
