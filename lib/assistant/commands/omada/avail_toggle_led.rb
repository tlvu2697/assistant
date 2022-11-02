# frozen_string_literal: true

module Assistant
  module Commands
    module Omada
      class AvailToggleLed < Base
        option 'client-ip', required: true, desc: 'Local IP of client to check availability'
        option 'eap-mac', required: true, desc: 'MAC address of EAP to toggle LED'

        # TODO: -- Optimization
        # 1. Save availability of client
        # 2. If availability changes => Login + Toggle LED
        # 3. If availability does not change => Skip
        def call(**options)
          client_ip = options.fetch(:'client-ip')
          eap_mac = options.fetch(:'eap-mac')

          username
          password
          auth

          client_availability = yield available?(client_ip)
          yield toggle_led(client_availability, eap_mac)

          Success()
        end

        def available?(client_ip)
          Assistant::Executor.instance.with_spinner(
            title: "Checking availability of \"#{Assistant::PASTEL.green(client_ip)}\""
          ) do
            Success(Net::Ping::External.new(client_ip).ping?)
          end
        end

        def toggle_led(client_availability, eap_mac)
          Assistant::Executor.instance.with_spinner(
            title: "Toggling LED of EAP \"#{Assistant::PASTEL.green(eap_mac)}\""
          ) do
            eap_repository.toggle_led(
              eap_mac: eap_mac,
              state: Assistant::Omada::EAP::LED_SETTINGS[client_availability]
            )
          end
        end
      end
    end
  end
end
