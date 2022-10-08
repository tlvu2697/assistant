# frozen_string_literal: true

module Assistant
  module CircleCI
    class BaseRepository
      include HTTParty
      base_uri 'circleci.com/api/v2'

      def initialize(circleci_token:)
        self.class.headers 'Circle-Token' => circleci_token
      end
    end
  end
end
