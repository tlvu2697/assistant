# frozen_string_literal: true

module Assistant
  class Tweaks
    class << self
      def fix_postman_openssl
        TTY::File.replace_in_file(
          '/opt/Postman/app/resources/app/node_modules/pem/lib/pem.js',
          /RSA PRIVATE/,
          'PRIVATE',
          verbose: false
        )
      end
    end
  end
end
