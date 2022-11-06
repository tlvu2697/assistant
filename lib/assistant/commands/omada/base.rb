# frozen_string_literal: true

module Assistant
  module Commands
    module Omada
      class Base < Dry::CLI::Command
        include Dry::Monads[:result, :do]

        private

        attr_reader :username, :password

        def prompt_fetch_username
          @username = Assistant::Config.instance.prompt_fetch(
            Assistant::Config::OMADA[:USERNAME]
          )
        end

        def prompt_fetch_password
          @password = Assistant::Config.instance.prompt_fetch(
            Assistant::Config::OMADA[:PASSWORD]
          )
        end

        def base_repository
          @base_repository ||= Assistant::Omada::BaseRepository.new
        end

        def eap_repository
          @eap_repository ||= Assistant::Omada::EAPRepository.new(
            auth: auth
          )
        end

        def auth
          @auth ||= Assistant::Executor.instance.with_spinner(title: 'Logging in') do
            auth_ = base_repository.login(
              username: username,
              password: password
            )
            message = auth_.either(
              ->(_) { 'done' },
              ->(error_message) { error_message }
            )

            [auth_, message]
          end.value!
        end
      end
    end
  end
end
