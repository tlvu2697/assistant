# frozen_string_literal: true

require 'English'
require 'clipboard'
require 'dry/cli'

require 'assistant/command'
require 'assistant/executor'
require 'assistant/version'

require 'assistant/commands'

module Assistant
  class Error < StandardError; end
end
