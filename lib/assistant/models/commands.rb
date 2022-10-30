# frozen_string_literal: true

module Assistant
  module Models
    class Commands < Base
      include Enumerable

      attr_reader :lines

      def initialize(lines)
        @lines = process(lines)
      end

      def each
        for line in lines do
          yield Assistant::Models::Command.new(line)
        end
      end

      def to_a
        lines.map { |line| Assistant::Models::Command.new(line) }
      end

      def to_ary
        to_a
      end

      private

      def process(lines)
        lines.split("\n").reject(&:empty?)
      end
    end
  end
end
