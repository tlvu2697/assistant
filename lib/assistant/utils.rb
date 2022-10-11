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
    end
  end
end
