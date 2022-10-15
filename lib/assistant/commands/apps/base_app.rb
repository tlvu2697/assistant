# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      class BaseApp < Dry::CLI::Command
        include Dry::Monads[:result, :do]

        BIN_DIR = "#{Dir.home}/.local/bin"
        TMP_DIR = "#{Dir.home}/.tmp"

        private

        def init
          TTY::File.create_dir(BIN_DIR)
          TTY::File.create_dir(TMP_DIR)
        end

        def download(metadata)
          Assistant::Executor.instance.with_spinner(title: 'Downloading') do
            Assistant::Executor.instance.sync(
              Assistant::Command.new("curl -sL -o #{metadata["filepath"]} #{metadata["url"]}")
            )

            Success('done')
          end
        end

        def clean(path)
          TTY::File.remove_file(path)
        end
      end
    end
  end
end
