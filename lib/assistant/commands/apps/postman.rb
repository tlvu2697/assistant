# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      class Postman < BaseApp
        def call(**)
          Assistant::Utils.request_sudo_permission!

          Assistant::Executor.instance.with_spinner(title: 'postman') do
            init
            download
            extract
            install
            tweak
            clean

            Success('done')
          end
        end

        def metadata
          return @metadata if defined? @metadata

          tmp_dir = "#{GLOBAL_TMP_DIR}/.postman"
          filename = 'linux.tar.gz'
          url = 'https://dl.pstmn.io/download/latest/linux64'

          @metadata = Metadata.new(
            current_version: nil,
            latest_version: nil,
            tmp_dir: tmp_dir,
            filename: filename,
            filepath: "#{tmp_dir}/#{filename}",
            url: url
          )
        end

        def extract
          Assistant::Executor.instance.capture(
            Assistant::Command.new(
              "tar xzf #{metadata.filepath} -C #{metadata.tmp_dir} > /dev/null"
            )
          )
        end

        def install
          TTY::File.create_file("#{metadata.tmp_dir}/Postman.desktop", <<~PLAINTEXT, force: true, verbose: false)
            [Desktop Entry]

            Name=Postman
            Exec=/opt/Postman/app/Postman %U
            Icon=/opt/Postman/app/resources/app/assets/icon.png
            Terminal=false
            Type=Application
            Categories=Development;
          PLAINTEXT

          Assistant::Executor.instance.capture(
            Assistant::Command.new(
              <<~BASH
                sudo rm -rf /opt/Postman
                sudo mv #{metadata.tmp_dir}/Postman /opt/Postman
                ln -s /opt/Postman/Postman ~/.local/bin
                sudo desktop-file-install #{metadata.tmp_dir}/Postman.desktop
              BASH
            )
          )
        end

        def tweak
          Assistant::Tweaks.fix_postman_openssl
        end
      end
    end
  end
end
