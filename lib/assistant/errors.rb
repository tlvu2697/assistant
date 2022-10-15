# frozen_string_literal: true

module Assistant
  class Error < StandardError
    def initialize(message = nil)
      super message || 'Something went wrong'
    end
  end

  class NotFoundError < StandardError; end
end
