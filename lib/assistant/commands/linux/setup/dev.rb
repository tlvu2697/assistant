# frozen_string_literal: true

module Assistant
  module Commands
    module Linux
      module Setup
        class Dev < ::Assistant::Commands::Linux::Base
          desc 'Setup DevTools'

          NODEJS_VERSION = '16.17.1'
          RUBY_VERSION = '3.1.2'
          PYTHON3_VERSION = '3.10.5'

          def call
            Assistant::Utils.request_sudo_permission!

            apps

            [
              configs, dev_tools, asdf, miscs
            ].flatten.each do |command|
              Assistant::Executor.instance.sync(command)
            end
          end

          def configs
            Assistant::Models::Command.new(<<~BASH)
              git config --global core.excludesfile $HOME/.gitignore_global
            BASH
          end

          def dev_tools
            Assistant::Models::Commands.new(<<~BASH)
              sudo add-apt-repository -y ppa:aslatter/ppa
              sudo apt update
              sudo apt install -y alacritty gh neovim
              git clone https://github.com/wbthomason/packer.nvim $HOME/.local/share/nvim/site/pack/packer/start/packer.nvim
            BASH
          end

          def asdf
            Assistant::Models::Commands.new(<<~BASH)
              git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf

              asdf plugin-add nodejs
              asdf plugin-add python
              asdf plugin-add ruby

              asdf install nodejs #{NODEJS_VERSION}
              asdf install python #{PYTHON3_VERSION}
              asdf install ruby #{RUBY_VERSION}

              asdf global nodejs #{NODEJS_VERSION}
              asdf global python #{PYTHON3_VERSION}
              asdf global ruby #{RUBY_VERSION}

              sudo ln -s $HOME/.asdf/shims/python3 /usr/local/bin/_python3

              pip3 install neovim
              npm install -g neovim
              gem install neovim
              gem install tmuxinator

              sudo ln -s $HOME/.asdf/installs/ruby/#{RUBY_VERSION}/bin/tmuxinator ~/.local/bin/muxinator
            BASH
          end

          def apps
            Assistant::Commands::Apps::Lazygit.call
            Assistant::Commands::Apps::Lazydocker.call
            Assistant::Commands::Apps::Overmind.call
          end

          def miscs
            Assistant::Models::Commands.new(<<~BASH)
              echo "https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-redis-on-ubuntu-20-04"
              echo "https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-18-04"
              echo "https://docs.docker.com/engine/install/ubuntu/"
            BASH
          end
        end
      end
    end
  end
end
