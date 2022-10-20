# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      Metadata = Struct.new(
        *%i[
          current_version
          latest_version
          tmp_dir
          filename
          filepath
          url
        ],
        keyword_init: true
      )

      class BaseApp < Dry::CLI::Command
        include Dry::Monads[:result, :do]

        GLOBAL_BIN_DIR = "#{Dir.home}/.local/bin"
        GLOBAL_TMP_DIR = "#{Dir.home}/.tmp"

        def request_sudo_permission
          sudo_password = Assistant::Config.instance.prompt(Assistant::Config::SUDO_PASSWORD_KEY)

          Assistant::Executor.instance.capture(
            Assistant::Command.new("sudo -S -p '' echo '' << '#{sudo_password}'")
          )
        end

        def call(**)
          Assistant::Executor.instance.with_spinner(title: bin_name) do
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

        def base_url
          raise NotImplementedError
        end

        def version_matcher
          raise NotImplementedError
        end

        def bin_name
          raise NotImplementedError
        end

        def metadata
          raise NotImplementedError
        end

        def os
          @os ||= Assistant::PLATFORM.os
        end

        def cpu
          @cpu ||= Assistant::PLATFORM.cpu
        end

        def validate_existence!
          return if metadata.current_version != metadata.latest_version

          raise Assistant::ExistedError, "#{metadata.current_version} - latest"
        end

        def init
          TTY::File.create_dir(GLOBAL_BIN_DIR, verbose: false)
          TTY::File.create_dir(GLOBAL_TMP_DIR, verbose: false)
          TTY::File.create_dir(metadata.tmp_dir, verbose: false)
        end

        def download
          Assistant::Executor.instance.capture(
            Assistant::Command.new("curl -sL -o #{metadata.filepath} #{metadata.url}")
          )
        end

        def current_version(command)
          return @current_version if defined? @current_version

          current_version_ = Assistant::Executor.instance.safe_capture(command).first

          @current_version = version_matcher.match(current_version_)&.[](:version) || 'none'
        end

        def latest_version
          return @latest_version if defined? @latest_version

          latest_version_ = HTTParty.get(
            "#{base_url}/releases/latest",
            headers: { 'Accept' => 'application/json' }
          )

          @latest_version = latest_version_['tag_name'].gsub('v', '')
        end

        def extract
          Assistant::Executor.instance.capture(
            Assistant::Command.new(
              "tar xzf #{metadata.filepath} -C #{metadata.tmp_dir} #{bin_name} > /dev/null"
            )
          )
        end

        def install
          command_string = if Assistant::PLATFORM.linux?
                             "install -m 755 #{metadata.tmp_dir}/#{bin_name} -t \"#{GLOBAL_BIN_DIR}\""
                           elsif Assistant::PLATFORM.mac?
                             "install -m 755 #{metadata.tmp_dir}/#{bin_name} #{GLOBAL_BIN_DIR}"
                           else
                             raise Assistant::Error, 'Unable to detect system'
                           end

          Assistant::Executor.instance.capture(
            Assistant::Command.new(command_string)
          )
        end

        def clean
          Assistant::Executor.instance.capture(
            Assistant::Command.new("rm -rf #{metadata.tmp_dir}")
          )
        end
      end
    end
  end
end
