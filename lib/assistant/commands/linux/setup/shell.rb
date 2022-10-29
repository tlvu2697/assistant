
module Assistant
  module Commands
    module Linux
      module Setup
        class Dev < ::Assistant::Commands::Linux::Base
          desc 'Setup Shell'

          def call
            [
              zsh,
              oh_my_zsh
            ]


          end

          def zsh
            Assistant::Models::Command.new(<<~BASH)
              sudo apt-get install -y zsh
              sudo chsh -s $(which zsh)
            BASH
          end

          def oh_my_zsh
            Assistant::Models::Command.new(<<~BASH)
              sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
              git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
            BASH
          end

        end
      end
    end
  end
end
