# frozen_string_literal: true

module Assistant
  module Models
    class Command < Base
      attr_reader :content

      def initialize(content)
        @content = content&.strip
      end
    end
  end
end
