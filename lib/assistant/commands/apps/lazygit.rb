# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      class Lazygit < BaseApp
        BASE_URL = 'https://github.com/jesseduffield/lazygit'
        VERSION_MATCHER = /version=(?<version>[^,]+)/.freeze
        BIN_NAME = 'lazygit'

        def call(**)
          Assistant::Executor.instance.with_spinner(title: 'lazygit') do
            validate_existence!

            init
            download
            extract
            install
            clean

            Success("#{metadata.current_version} -> #{metadata.latest_version}")
          end
        end

        private

        def current_version
          return @current_version if defined? @current_version

          current_version_ = Assistant::Executor.instance.safe_capture(
            Assistant::Command.new('lazygit --version')
          ).first

          @current_version = VERSION_MATCHER.match(current_version_)&.[](:version) || 'none'
        end

        def latest_version
          return @latest_version if defined? @latest_version

          latest_version_ = HTTParty.get(
            "#{BASE_URL}/releases/latest",
            headers: { 'Accept' => 'application/json' }
          )

          @latest_version = latest_version_['tag_name'].gsub('v', '')
        end

        def metadata
          return @metadata if defined? @metadata

          tmp_dir = "#{GLOBAL_BIN_DIR}/.lazygit"
          filename = "lazygit_#{latest_version}_#{Assistant::PLATFORM.os.capitalize}_#{Assistant::PLATFORM.cpu}.tar.gz"
          url = "#{BASE_URL}/releases/download/v#{latest_version}/#{filename}"

          @metadata = Metadata.new(
            current_version: current_version,
            latest_version: latest_version,
            tmp_dir: tmp_dir,
            filename: filename,
            filepath: "#{tmp_dir}/#{filename}",
            url: url
          )
        end

        def extract
          Assistant::Executor.instance.capture(
            Assistant::Command.new(
              "tar xzvf #{metadata.filepath} -C #{metadata.tmp_dir} #{BIN_NAME} > /dev/null"
            )
          )
        end

        def install
          command_string = if Assistant::PLATFORM.linux?
                             "install -m 755 #{metadata.tmp_dir}/#{BIN_NAME} -t \"#{GLOBAL_BIN_DIR}\""
                           elsif Assistant::PLATFORM.mac?
                             "install -m 755 #{metadata.tmp_dir}/#{BIN_NAME} #{GLOBAL_BIN_DIR}"
                           else
                             raise Assistant::Error, 'Unable to detect system'
                           end

          Assistant::Executor.instance.capture(
            Assistant::Command.new(command_string)
          )
        end
      end
    end
  end
end
