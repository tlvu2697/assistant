# frozen_string_literal: true

module Assistant
  module Commands
    module CircleCI
      class Approve < Dry::CLI::Command
        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)
      end
    end
  end
end
