# frozen_string_literal: true

module Assistant
  module Commands
    module Linux
      class Tweak < Dry::CLI::Command
        include Dry::Monads[:result]

        desc 'Linux tweaks that make your life better'

        def call(**)
          Assistant::Executor.instance.with_spinner(title: 'Deploying tweaks') do
            Assistant::Tweaks.fix_postman_openssl

            Success('done')
          end
        end
      end
    end
  end
end
