# frozen_string_literal: true

module Assistant
  module Omada
    class Client
      attr_reader :id, :mac, :ip, :active

      def initialize(data)
        @id = data['id']
        @mac = data['mac']
        @ip = data['ip']
        @active = data['active']
      end
    end

    class ClientRepository < BaseRepository
      def get(client_mac:, site: DEFAULT_SITE)
        response = self.class.get(
          "/sites/#{site}/clients/#{client_mac}"
        )

        json_response = JSON.parse(response.body)
        message = json_response['msg']
        status = json_response['errorCode']
        result = json_response['result']

        status.zero? ? Success(Client.new(result)) : Failure(message)
      end
    end
  end
end
