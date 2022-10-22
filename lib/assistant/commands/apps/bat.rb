# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      class Bat < Base
        private

        VERSION_MATCHER = /bat (?<version>.*) \(.*\)/.freeze

        def current_version
          @current_version ||= VERSION_MATCHER.match(
            Assistant::Executor.instance.capture(Assistant::Command.new('bat --version'))
          )&.[](:version)
        end
      end
    end
  end
end
