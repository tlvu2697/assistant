# frozen_string_literal: true

module Assistant
  module Commands
    module Linux
      class Clean < Base
        desc 'Clean residual configs'

        def call(**)
          Assistant::Utils.request_sudo_permission!

          Assistant::Executor.instance.sync(clean_apt_packages_command)
          Assistant::Executor.instance.sync(clean_snaps_command)
        end

        private

        def clean_apt_packages_command
          Assistant::Models::Command.new(
            <<~BASH
              sudo apt --purge --yes autoremove
            BASH
          )
        end

        def clean_snaps_command
          Assistant::Models::Command.new(
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
