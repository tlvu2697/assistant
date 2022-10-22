# frozen_string_literal: true

module Assistant
  module Commands
    module Macos
      class Base < Dry::CLI::Command
        include Dry::Monads[:result, :do]
      end
    end
  end
end
