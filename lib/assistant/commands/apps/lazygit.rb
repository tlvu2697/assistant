# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      class Lazygit < BaseApp
        BASE_URL = 'https://github.com/jesseduffield/lazygit'
        VERSION_MATCHER = /version=(?<version>[^,]+)/.freeze
        BIN_NAME = 'lazygit'

        def call(**)
          current_version = yield fetch_current_version
          latest_version = yield fetch_latest_version
          metadata = yield build_metadata(latest_version)

          Success()
        end

        private

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

        def build_metadata(latest_version)
          filename = "lazygit_#{latest_version}_#{Assistant::PLATFORM.os.capitalize}_#{Assistant::PLATFORM.cpu}.tar.gz"
          url = "#{BASE_URL}/releases/download/#{latest_version}/#{filename}"

          Success({
            'filename' => filename,
            'filepath' => "#{TMP_DIR}/#{filename}",
            'url' => url
          })
        end

        def extract(metadata)
          Assistant::Executor.instance.with_spinner(title: 'Extracting') do
            current_version_ = Assistant::Executor.instance.safe_capture(
              Assistant::Command.new(
                "tar xzvf #{metadata["filepath"]} -C #{BIN_DIR} #{BIN_NAME} > /dev/null"
              )
            ).first

            Success('done')
          end
        end

        def install()

  curl -sL -o .tmp/lazygit.tar.gz $GITHUB_URL
  tar xzvf ~/.tmp/lazygit.tar.gz -C ~/.tmp lazygit > /dev/null
  install -Dm 755 tmp/lazygit -t "$DIR"
  echo "[*] lazygit (${CURRENT_VERSION} -> ${GITHUB_LATEST_VERSION})"
  rm -rf tmp
        end

        def clean
      end
    end
  end
end
