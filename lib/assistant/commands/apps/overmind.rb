# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      class Overmind < Base
        private

        def base_url
          @base_url ||= 'https://github.com/DarthSim/overmind'
        end

        def version_matcher
          @version_matcher ||= /Overmind version (?<version>.+)/.freeze
        end

        def bin_name
          @bin_name ||= 'overmind'
        end

        def os
          @os ||= case Assistant::PLATFORM.os
                  when TTY::Platform::MAC_PATTERN
                    'macos'
                  else
                    Assistant::PLATFORM.os
                  end
        end

        def cpu
          @cpu ||= case Assistant::PLATFORM.cpu
                   when 'x86_64'
                     'amd64'
                   else
                     Assistant::PLATFORM.cpu
                   end
        end

        def metadata
          return @metadata if defined? @metadata

          tmp_dir = "#{GLOBAL_TMP_DIR}/.#{bin_name}"
          filename = "#{bin_name}_#{latest_version}_#{os.capitalize}_#{cpu}.tar.gz"
          url = "#{base_url}/releases/download/v#{latest_version}/#{filename}"

          @metadata = Metadata.new(
            current_version: current_version(Assistant::Command.new('overmind --version')),
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
