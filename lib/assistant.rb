# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
require 'clipboard'
require 'dry/cli'
require 'English'
require 'httparty'
require 'tty-config'
require 'tty-logger'
require 'pastel'
require 'tty-command'
require 'tty-prompt'
require 'tty-spinner'

require 'assistant/utils'
require 'assistant/circleci'
require 'assistant/command'
require 'assistant/config'
require 'assistant/executor'
require 'assistant/version'
require 'assistant/commands'

module Assistant
  class Error < StandardError; end
  class NotFoundError < StandardError; end

  CMD = TTY::Command.new(printer: :pretty)
  QUIET_CMD = TTY::Command.new(printer: :null)
  PROMPT = TTY::Prompt.new
  PASTEL = Pastel.new
  SPINNER = TTY::Spinner.new('[:spinner] :title', format: :dots, success_mark: '+', error_mark: '-')

  class << self
    def with_spinner(title:, success: nil, error: nil, &block)
      success_message = success ? "(#{success})" : ''
      error_message = error ? "(#{error})" : ''
      result = nil
      SPINNER.update(title: title)
      SPINNER.run do |spinner|
        result = yield block
        result ? spinner.success(success_message) : spinner.error(error_message)
      end
      result
    end
  end
end
