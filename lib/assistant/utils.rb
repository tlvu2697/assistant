# frozen_string_literal: true

module Assistant
  class Utils
    class << self
      def spinner_success_format(message)
        "(#{Assistant::PASTEL.green(message)})"
      end
    end
  end
end
