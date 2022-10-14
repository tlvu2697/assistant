# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      class Lazygit < BaseApp
        def call(**)
          current_version = yield fetch_current_version
          latest_version = yield fetch_latest_version

          Success()
        end

        private

        BASE_URL = 'https://github.com/jesseduffield/lazygit'
        VERSION_MATCHER = /version=(?<version>[^,]+)/.freeze

        def fetch_current_version
          Assistant::Executor.instance.with_spinner(title: 'Fetching current version') do
            current_version_ = Assistant::Executor.instance.safe_capture(
              Assistant::Command.new('lazygitt --version')
            ).first

            Success(VERSION_MATCHER.match(current_version_)&.[](:version) || 'none')
          end
        end

        def fetch_latest_version
          Assistant::Executor.instance.with_spinner(title: 'Fetching latest version') do
            latest_version_ = HTTParty.get(
              "#{BASE_URL}/releases/latest",
              headers: { 'Accept' => 'application/json' }
            )

            Success(latest_version_['tag_name'].gsub('v', ''))
          end
        end

        def github_url(latest_version)
          filename = "lazygit_#{latest_version}_#{Assistant::PLATFORM.os.capitalize}_#{Assistant::PLATFORM.cpu}.tar.gz"

        end
      end
    end
  end
end
