# frozen_string_literal: true

module Assistant
  module Commands
    module Omada
      class CertificationConvert < Base
        option :'ca-bundle',   default: 'ca_bundle.crt',   desc: 'Intermediate certificate (ca-bundle.crt)'
        option :certificate,   default: 'certificate.crt', desc: 'Primary SSL certificate (certificate.crt)'
        option :'private-key', default: 'private.key',     desc: 'Private key (private.key)'
        option :out,           default: 'certificate.pfx', desc: 'SSL certificate in PKCS12 format (.pfx)'

        def call(**options)
          @ca_bundle_path = options.fetch(:'ca-bundle')
          @certificate_path = options.fetch(:certificate)
          @private_key_path = options.fetch(:'private-key')
          @out_path = options.fetch(:out)
          @compined_certificate_path = 'compined-certificate.crt'

          compine_certificates(
            @certificate_path,
            @ca_bundle_path
          )

          Assistant::Executor.instance.sync(
            Assistant::Models::Command.new(
              <<~BASH
                openssl pkcs12 -export -out #{@out_path} -inkey #{@private_key_path} -in #{@compined_certificate_path}
              BASH
            )
          )

          TTY::File.remove_file(@compined_certificate_path)

          Success('done')
        end

        private

        def compine_certificates(*certificate_paths)
          TTY::File.create_file(@compined_certificate_path, '')

          certificate_paths.each do |certificate_path|
            TTY::File.append_to_file(@compined_certificate_path) do
              TTY::File.read_to_char(certificate_path, verbose: false)
            end
          end
        end
      end
    end
  end
end
