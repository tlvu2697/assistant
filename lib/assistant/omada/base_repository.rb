# frozen_string_literal: true

module Assistant
  module Omada
    Auth = Struct.new(
      *%i[
        tpeap_sessionid
        csrf_token
      ],
      keyword_init: true
    )

    class BaseRepository
      DEFAULT_OMADA_CID = '1af9b1e833bf59d6f3664ca1fe61f9ee'
      DEFAULT_SITE = 'Default'

      include Dry::Monads[:result, :do]
      include HTTParty
      headers 'Content-Type' => 'application/json'

      def initialize(auth: nil, omada_cid: DEFAULT_OMADA_CID)
        @auth = auth
        @omada_cid = omada_cid

        self.class.base_uri "https://home.vutran.cyou:8443/#{@omada_cid}/api/v2"
        authorizable(@auth) if @auth
      end

      def authorizable(auth)
        self.class.headers 'Csrf-Token' => auth.csrf_token
        self.class.default_cookies.add_cookies(auth.tpeap_sessionid)
      end

      def login(username:, password:)
        response = self.class.post('/login', body: { username: username, password: password }.to_json, verify: false)

        if response.success?
          auth = Auth.new(
            tpeap_sessionid: response.headers['set-cookie'],
            csrf_token: JSON.parse(response.body).dig('result', 'token')
          )

          authorizable(auth)
          Success(auth)
        else
          on_fail
        end
      end

      private

      def on_fail
        Failure('Something went wrong')
      end
    end
  end
end
