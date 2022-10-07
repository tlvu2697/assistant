# frozen_string_literal: true

require 'singleton'
require 'json'

module Assistant
  class Configuration
    include Singleton

    CONFIG_FILE_PATH = '~/.assistant.config.json'

    AVAILABLE_CONFIGS = %w[
      circle_token
    ].freeze

    AVAILABLE_CONFIGS.each do |available_config|
      define_method available_config do
        get(key: available_config)
      end

      define_method "#{available_config}=" do |value|
        set(key: available_config, value: value)
        save
      end
    end

    private

    def initialize
      load
    end

    def configs
      @configs ||= {}
    end

    def validate!(key:)
      raise Assistant::NotFoundError unless AVAILABLE_CONFIGS.include?(key.to_s)
    end

    def get(key:)
      validate!(key: key)

      configs[key.to_s]
    end

    def set(key:, value:)
      validate!(key: key)

      configs[key.to_s] = value
    end

    def load
      config_path = File.expand_path(CONFIG_FILE_PATH)

      @configs = begin
        JSON.parse(File.read(config_path))
      rescue StandardError
        save
        {}
      end
    end

    def save
      File.write(
        File.expand_path(CONFIG_FILE_PATH),
        JSON.pretty_generate(configs)
      )
    end
  end
end
