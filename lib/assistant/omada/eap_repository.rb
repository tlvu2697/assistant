# frozen_string_literal: true

module Assistant
  module Omada
    class EAP
      attr_reader :id, :number, :revision, :created_at

      LED_SETTINGS = {
        true => 1,
        false => 0,
        off: 0,
        on: 1,
        variable: 2
      }.freeze

      def initialize(data)
        @data = data
      end
    end

    class EAPRepository < BaseRepository
      def toggle_led(eap_mac:, state:, site: DEFAULT_SITE)
        response = self.class.patch(
          "/sites/#{site}/eaps/#{eap_mac}",
          body: { ledSetting: state }.to_json
        )

        json_response = JSON.parse(response.body)
        message = json_response['msg']
        status = json_response['errorCode']

        status.zero? ? Success(message) : Failure(message)
      end
    end
  end
end
