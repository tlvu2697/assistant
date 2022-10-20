# frozen_string_literal: true

module Assistant
  module Commands
    module Linux
      class Update < Dry::CLI::Command
        include Dry::Monads[:result]

        desc 'Update applications'

        def call(**)
          Assistant::Commands::Apps::Lazygit.call
          Assistant::Commands::Apps::Lazydocker.call
          Assistant::Commands::Apps::Grpcurl.call

          update_asdf
          update_omz
          update_snaps
        end

        private

        def update_asdf
          Assistant::Executor.instance.with_spinner(title: 'asdf') do
            Assistant::Executor.instance.safe_capture(
              Assistant::Command.new(<<~BASH)
                asdf update
                asdf reshim
                asdf plugin update --all
              BASH
            )

            Success('done')
          end
        end

        def update_omz
          Assistant::Executor.instance.with_spinner(title: 'omz') do
            Assistant::Executor.instance.safe_capture(
              Assistant::Command.new('omz update')
            )

            Success('done')
          end
        end

        def update_snaps
          Assistant::Utils.request_sudo_permission!

          Assistant::Executor.instance.with_spinner(title: 'snaps') do
            Assistant::Executor.instance.safe_capture(
              Assistant::Command.new(<<~BASH)
                snap-store --quit
                sudo snap refresh
              BASH
            )

            Success('done')
          end
        end
      end
    end
  end
end
