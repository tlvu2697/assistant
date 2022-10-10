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

    def capture(command)
      Assistant::QUIET_CMD.run(command.content)
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
