# frozen_string_literal: true

module Assistant
  module Models
    class Command < Base
      def initialize(content)
        @content = content&.strip
      end

      def content
        'echo 1'
      end
    end
  end
end
