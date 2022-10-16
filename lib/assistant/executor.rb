# frozen_string_literal: true

module Assistant
  class Executor
    include Singleton
    include Dry::Monads[:result]

    def sync(command)
      Assistant::CMD.run(command.content)
    end

    def await(&block)
      block&.call(method(:async))
      Process.waitall
    end

    def capture(command)
      Assistant::QUIET_CMD.run(command.content)
    end

    def safe_capture(command)
      Assistant::QUIET_CMD.run(command.content)
    rescue StandardError
      TTY::Command::Result.new(nil, nil, nil)
    end

    def with_spinner(title:, &block)
      result_ = nil

      spinner_ = Assistant.spinner
      spinner_.update(title: title)
      spinner_.run do |spinner|
        begin
          # https://dry-rb.org/gems/dry-monads/1.3/result/#code-either-code
          # Use either to generate for Success / Failure
          result_, message = block.call(spinner)

          if result_.success?
            spinner.success(Assistant::Utils.format_spinner_success(message || result_.value!))
          else
            spinner.error(Assistant::Utils.format_spinner_error(message || result_.failure))
          end
        rescue Dry::Monads::Do::Halt
          result_ = Failure('halt')

          spinner.error(Assistant::Utils.format_spinner_error(result_.failure))
        rescue StandardError => e
          result_ = Failure(e.message)

          spinner.error(Assistant::Utils.format_spinner_error(result_.failure))
        end
      end

      result_
    end

    private

    def async(*commands)
      commands.each do |command|
        fork { sync(command) }
      end
    end

    # TODO: Select executor based on OS
    def os_executor
      @os_executor ||= system
    end
  end
end
