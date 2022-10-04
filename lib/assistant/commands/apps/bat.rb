# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      class Bat < BaseApp
        private

        VERSION_MATCHER = /bat (?<version>.*) \(.*\)/.freeze

        def current_version
          @current_version ||= VERSION_MATCHER.match(
            Assistant::Executor.capture(Assistant::Command.new('bat --version'))
          )&.[](:version)
        end
      end
    end
  end
end
