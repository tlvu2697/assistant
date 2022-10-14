# frozen_string_literal: true

module Assistant
  module Commands
    module Apps
      class BaseApp < Dry::CLI::Command
        include Dry::Monads[:result, :do]
      end
    end
  end
end
