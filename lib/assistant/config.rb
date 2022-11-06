# frozen_string_literal: true

module Assistant
  class YAMLMarshaller < TTY::Config::Marshallers::YAMLMarshaller
    def unmarshal(content)
      YAML.safe_load content, permitted_classes: [Symbol]
    end
  end

  class Config
    include Singleton
    include Configurable
    include Dry::Monads[:result]

    extend Forwardable
    def_delegators :storage, :fetch, :set

    def prompt_fetch(*args, **kwargs)
      key = Array(args).join('.')

      if (value = fetch(key))
        return value
      end

      value = prompt(*args, **kwargs)
      set!(key, value: value)
      fetch(key)
    end

    def prompt(*args, **kwargs)
      key = Array(args).join('.')

      with_key = Assistant::PASTEL.bold(key)
      with_hint = kwargs[:hint].nil? ? ':' : " (#{Assistant::PASTEL.bright_blue(kwargs[:hint])}):"

      Assistant::PROMPT.mask(
        "Hi there, I need your \"#{with_key}\" to continue#{with_hint}"
      ) do |q|
        q.required true
      end
    end

    %i[set append remove].each do |method_name|
      bang_method_name = "#{method_name}!"

      define_method bang_method_name do |*args, **kwargs, &block|
        enhance do |s|
          s.send(method_name, *args, **kwargs, &block)
        end
      end
    end

    private

    def enhance
      return unless block_given?

      mutex = Mutex.new
      mutex.synchronize do
        yield storage
        storage.write(force: true)
      end
    end

    def storage
      @storage ||= begin
        storage = TTY::Config.new
        storage.filename = '.assistant'
        storage.extname = '.yaml'
        storage.append_path(Dir.home)
        storage.unregister_marshaller(:yaml)
        storage.register_marshaller(:assistant_yamlmarshaller, Assistant::YAMLMarshaller)

        begin
          storage.read
        rescue TTY::Config::ReadError
          storage.write(create: true, force: true)
        end

        storage
      end
    end
  end
end
