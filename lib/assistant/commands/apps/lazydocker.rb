# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      class Lazydocker < Base
        private

        def base_url
          @base_url ||= 'https://github.com/jesseduffield/lazydocker'
        end

        def version_matcher
          @version_matcher ||= /Version: (?<version>.+)/.freeze
        end

        def bin_name
          @bin_name ||= 'lazydocker'
        end

        def metadata
          return @metadata if defined? @metadata

          tmp_dir = "#{GLOBAL_TMP_DIR}/.#{bin_name}"
          filename = "#{bin_name}_#{latest_version}_#{os.capitalize}_#{cpu}.tar.gz"
          url = "#{base_url}/releases/download/v#{latest_version}/#{filename}"

          @metadata = Metadata.new(
            current_version: current_version(Assistant::Command.new('lazydocker --version')),
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
