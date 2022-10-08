# frozen_string_literal: true

module Assistant
  class Executor
    include Singleton

    def sync(command)
      Assistant::CMD.run(command.content)
    end

    def await(&block)
      instance_exec(&block) if block_given?
      Process.waitall
    end

    # ref: https://stackoverflow.com/a/20001569
    def capture(command)
      stdout, _, status = Open3.capture3(command.content)
      status.success? && stdout.slice!(0..-(1 + $INPUT_RECORD_SEPARATOR.size))
    rescue StandardError
      nil
    end

    private

    def async(*commands)
      commands.each do |command|
        fork { Assistant::CMD.run(command.content) }
      end
    end

    # TODO: Select executor based on OS
    def os_executor
      @os_executor ||= system
    end
  end
end
