# frozen_string_literal: true

module Assistant
  module Commands
    module Omada
      class AvailabilityNotify < Base
        option 'client-ip', desc: 'Local IP of client to check availability'
        option 'eap-mac', desc: 'MAC address of EAP to toggle LED'
        option 'username', desc: 'Omada username'
        option 'password', desc: 'Omada password'

        def call(**options)
          @client_ip = options.fetch(:'client-ip')
          @eap_mac = options.fetch(:'eap-mac')
          @username = options[:username] || prompt_fetch_username
          @password = options[:password] || prompt_fetch_password

          eap_led_setting = yield fetch_client_availability
          cached_eap_led_setting = fetch_cached_eap_led_setting

          return unless cached_eap_led_setting.nil? || cached_eap_led_setting != eap_led_setting

          cache_eap_led_setting(eap_led_setting)
          yield update_eap_led_setting(eap_led_setting)
        end

        private

        def fetch_client_availability
          Assistant::Executor.instance.with_spinner(
            title: "Checking availability of \"#{Assistant::PASTEL.green(@client_ip)}\""
          ) do
            Success(Net::Ping::External.new(@client_ip).ping?)
          end
        end

        def fetch_cached_eap_led_setting
          Assistant::Config.instance.fetch(
            "#{Assistant::Config::OMADA[:AVAILABILITIES]}.#{@eap_mac}"
          )
        end

        def cache_eap_led_setting(led_setting)
          Assistant::Config.instance.set!(
            "#{Assistant::Config::OMADA[:AVAILABILITIES]}.#{@eap_mac}",
            value: led_setting
          )
        end

        def update_eap_led_setting(led_setting)
          auth
          action = led_setting ? 'Turn on' : 'Turn off'

          Assistant::Executor.instance.with_spinner(
            title: "#{action} LED of EAP \"#{Assistant::PASTEL.green(@eap_mac)}\""
          ) do
            eap_repository.toggle_led(
              eap_mac: @eap_mac,
              state: Assistant::Omada::EAP::LED_SETTINGS[led_setting]
            )
          end
        end
      end
    end
  end
end
