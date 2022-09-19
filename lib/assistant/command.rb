# frozen_string_literal: true

module Assistant
  class Command
    attr_reader :content

    def initialize(content)
      @content = content
    end
  end
end
