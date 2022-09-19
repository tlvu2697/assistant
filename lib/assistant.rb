# frozen_string_literal: true

require 'clipboard'
require 'dry/cli'
require 'require_all'
require 'byebug'

require 'assistant/command'
require 'assistant/executor'
require 'assistant/version'
require 'assistant/commands'

module Assistant
  class Error < StandardError; end
  # Your code goes here...
end
