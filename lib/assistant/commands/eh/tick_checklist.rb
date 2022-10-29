# frozen_string_literal: true

module Assistant
  module Commands
    module EH
      class TickChecklist < Dry::CLI::Command
        desc 'Tick the Github PR Checklists'

        def call(**)
          content = Clipboard.paste
          Clipboard.copy(tick(strip_spaces(content)))

          Assistant::Executor.sync(
            Assistant::Models::Command.new(
              <<~BASH
                notify-send 'Description updated'
              BASH
            )
          )
        end

        private

        def strip_spaces(content)
          content.gsub(/ - \[ \]/, '- [ ]')
        end

        def tick(content)
          content.gsub(/- \[ \]/, '- [x]')
        end
      end
    end
  end
end
