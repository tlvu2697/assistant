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
        SUDO_PASSWORD = 'sudo_password'

        def request_sudo_permission
          sudo_password = Assistant::Config.instance.prompt(SUDO_PASSWORD)

          Assistant::Executor.instance.capture(
            Assistant::Command.new("sudo -S -p '' echo '' << '#{sudo_password}'")
          )
        end

        private

        def validate_existence!
          return if metadata.current_version != metadata.latest_version

          raise Assistant::ExistedError, "#{metadata.current_version} - latest"
        end

        def metadata
          raise NotImplementedError
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

        def clean
          Assistant::Executor.instance.capture(
            Assistant::Command.new("rm -rf #{metadata.tmp_dir}")
          )
        end
      end
    end
  end
end
