# frozen_string_literal: true

module Assistant
  class Executor
    # ref: https://stackoverflow.com/a/20001569
    def self.sync(command)
      stdout, _, status = Open3.capture3(command.content)
      status.success? && stdout.slice!(0..-(1 + $INPUT_RECORD_SEPARATOR.size))
    end

    def self.async(*commands)
      commands.each do |command|
        fork { system(command.content) }
      end

      self
    end

    def self.await
      Process.waitall
    end

    private

    # TODO: Select executor based on OS
    def os_executor
      @os_executor ||= system
    end
  end
end
