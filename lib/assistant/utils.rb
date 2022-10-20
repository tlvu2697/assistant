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

        # TODO: fix me
        Assistant::Executor.instance.capture(
          Assistant::Command.new("sudo -S -p '' echo '' <<< '#{sudo_password}'")
        )
      end
    end
  end
end
