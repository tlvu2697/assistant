# frozen_string_literal: true

require 'singleton'
require 'json'

module Assistant
  class Config
    include Singleton

    extend Forwardable
    def_delegators :storage, :fetch, :set

    def prompt_fetch(*args)
      key = Array(args).join('.')

      if (value = fetch(key))
        return value
      end

      value = Assistant::PROMPT.mask(
        "Hi there, I need your \"#{Assistant::PASTEL.bold(key)}\" to continue:"
      ) do |q|
        q.required true
      end

      set!(key, value: value)
      fetch(key)
    end

    def set!(*args, **kwargs, &block)
      storage.set(*args, **kwargs, &block)
      storage.write(force: true)
    end

    private

    def storage
      @storage ||= Assistant.with_spinner(title: 'Loading configurations') do
        begin
          storage = TTY::Config.new
          storage.filename = '.assistant'
          storage.extname = '.yaml'
          storage.append_path(Dir.home)
          storage.read
          storage
        rescue TTY::Config::ReadError
          storage.write(create: true, force: true)
          storage
        end
      end
    end
  end
end
