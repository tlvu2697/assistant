# frozen_string_literal: true

module Assistant
  module Models
    class Commands < Base
      attr_reader :contents

      def initialize(contents)
        @contents = process(contents)
      end

      def detach

      end

      private

      def process(contents)
        contents.split("\n").reject(&:empty?)
      end
    end
  end
end
