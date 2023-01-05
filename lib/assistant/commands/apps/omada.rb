# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      class Omada < Base
        desc 'Clean residual configs'

        def call(**)
          Assistant::Executor.instance.sync(stop_container)
          Assistant::Executor.instance.sync(remove_container)
          Assistant::Executor.instance.sync(remove_image)
          Assistant::Executor.instance.sync(start_container)
        end

        private

        def stop_container
          Assistant::Models::Command.new(
            <<~BASH
              docker container stop omada-controller
            BASH
          )
        end

        def remove_container
          Assistant::Models::Command.new(
            <<~BASH
              docker rm omada-controller
            BASH
          )
        end

        def remove_image
          Assistant::Models::Command.new(
            <<~BASH
              docker rmi mbentley/omada-controller:latest
            BASH
          )
        end

        def start_container
          Assistant::Models::Command.new(
            <<~BASH
              docker run -d \
                --name omada-controller \
                --restart unless-stopped \
                --net host \
                -e MANAGE_HTTP_PORT=8000 \
                -e MANAGE_HTTPS_PORT=8443 \
                -e SHOW_SERVER_LOGS=true \
                -e SHOW_MONGODB_LOGS=false \
                -e SSL_CERT_NAME="tls.crt" \
                -e SSL_KEY_NAME="tls.key" \
                -e TZ=Etc/UTC \
                -v omada-data:/opt/tplink/EAPController/data \
                -v omada-work:/opt/tplink/EAPController/work \
                -v omada-logs:/opt/tplink/EAPController/logs \
                -v omada-cert:/cert \
                mbentley/omada-controller:latest
            BASH
          )
        end
      end
    end
  end
end
