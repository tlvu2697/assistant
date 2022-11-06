# frozen_string_literal: true

module Assistant
  module Configurable
    CIRLCECI_TOKEN_KEY = 'circleci_token'
    SUDO_PASSWORD_KEY = 'sudo_password'
    OMADA = {
      USERNAME: 'omada.username',
      PASSWORD: 'omada.password',
      AVAILABILITIES: 'omada.availabilities'
    }.freeze
  end
end
