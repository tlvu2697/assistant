# frozen_string_literal: true

module Assistant
  class Utils
    class << self
      def format_spinner_success(message)
        "(#{Assistant::PASTEL.green(message)})"
      end

      def format_spinner_error(message)
        "(#{Assistant::PASTEL.red(message)})"
      end

      def request_sudo_permission!
        sudo_password = Assistant::Config.instance.prompt(Assistant::Config::SUDO_PASSWORD_KEY)

        command_string = case Assistant::PLATFORM.os
                         when TTY::Platform::LINUX_PATTERN
                           "sudo -S -p '' echo '' << '#{sudo_password}'"
                         else
                           "sudo -S -p '' echo '' <<< '#{sudo_password}'"
                         end

        Assistant::Executor.instance.capture(
          Assistant::Models::Command.new(command_string)
        )
      end
    end
  end
end
