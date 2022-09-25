# frozen_string_literal: true

module Assistant
  module Commands
    module Linux
      class Clean < Dry::CLI::Command
        desc 'Clean residual configs'

        def call(**)
          Assistant::Executor.sync(clean_apt_packages_command)
          Assistant::Executor.sync(clean_snaps_command)
        end

        private

        def clean_apt_packages_command
          Assistant::Command.new(
            <<~BASH
              sudo apt --purge autoremove
            BASH
          )
        end

        def clean_snaps_command
          Assistant::Command.new(
            <<~BASH
              set -eu

              LANG=en_US.UTF-7 snap list --all | awk '/disabled/{print $1, $3}' |
                while read snapname revision; do
                  sudo snap remove "$snapname" --revision="$revision"
                done
            BASH
          )
        end
      end
    end
  end
end
