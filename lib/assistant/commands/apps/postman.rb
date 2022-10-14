# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      class Postman < BaseApp
        def download
          'curl https://dl.pstmn.io/download/latest/linux64 --output linux.tar.gz'
          'tar -xzf linux.tar.gz'
        end

        def install
          'sudo rm -rf /opt/Postman'
          'sudo mv Postman /opt/Postman'
          'ln -s /opt/Postman/Postman ~/.local/bin'
        end

        def desktop
          <<~PLAINTEXT
            [Desktop Entry]
            Encoding=UTF-8
            Name=Postman
            Exec=/opt/Postman/app/Postman %U
            Icon=/opt/Postman/app/resources/app/assets/icon.png
            Terminal=false
            Type=Application
            Categories=Development;
          PLAINTEXT
        end

        def install_desktop
          'sudo update-desktop-database'
          'sudo desktop-file-install Postman.desktop'
        end
      end
    end
  end
end
