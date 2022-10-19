# frozen_string_literal: true

require 'singleton'
require 'json'

module Assistant
  class Config
    include Singleton
    include Dry::Monads[:result]

    CIRLCECI_TOKEN_KEY = 'circleci_token'
    SUDO_PASSWORD_KEY = 'sudo_password'

    extend Forwardable
    def_delegators :storage, :fetch, :set

    def prompt_fetch(*args)
      key = Array(args).join('.')

      if (value = fetch(key))
        return value
      end

      value = prompt(args)
      set!(key, value: value)
      fetch(key)
    end

    def prompt(*args)
      key = Array(args).join('.')

      Assistant::PROMPT.mask(
        "Hi there, I need your \"#{Assistant::PASTEL.bold(key)}\" to continue:"
      ) do |q|
        q.required true
      end
    end

    def set!(*args, **kwargs, &block)
      storage.set(*args, **kwargs, &block)
      storage.write(force: true)
    end

    private

    def storage
      @storage ||= Assistant::Executor.instance.with_spinner(title: 'Loading configurations') do
        storage = TTY::Config.new
        storage.filename = '.assistant'
        storage.extname = '.yaml'
        storage.append_path(Dir.home)

        begin
          storage.read
        rescue TTY::Config::ReadError
          storage.write(create: true, force: true)
        end

        [Success(storage), 'done']
      end.value!
    end
  end
end
