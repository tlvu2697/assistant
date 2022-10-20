# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      class Grpcurl < BaseApp
        private

        def base_url
          @base_url ||= 'https://github.com/fullstorydev/grpcurl'
        end

        def version_matcher
          @version_matcher ||= /grpcurl v(?<version>.+)/.freeze
        end

        def bin_name
          @bin_name ||= 'grpcurl'
        end

        def os
          @os ||= case Assistant::PLATFORM.os
                  when TTY::Platform::MAC_PATTERN
                    'osx'
                  else
                    Assistant::PLATFORM.os
                  end
        end

        def current_version(command)
          return @current_version if defined? @current_version

          current_version_ = Assistant::Executor.instance.safe_capture(command).err.strip

          @current_version = version_matcher.match(current_version_)&.[](:version) || 'none'
        end

        def metadata
          return @metadata if defined? @metadata

          tmp_dir = "#{GLOBAL_TMP_DIR}/.#{bin_name}"
          filename = "#{bin_name}_#{latest_version}_#{os}_#{cpu}.tar.gz"
          url = "#{base_url}/releases/download/v#{latest_version}/#{filename}"

          @metadata = Metadata.new(
            current_version: current_version(Assistant::Command.new('grpcurl --version')),
            latest_version: latest_version,
            tmp_dir: tmp_dir,
            filename: filename,
            filepath: "#{tmp_dir}/#{filename}",
            url: url
          )
        end
      end
    end
  end
end
