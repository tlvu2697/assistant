# frozen_string_literal: true

module Assistant
  module Commands
    module Linux
      class Stress < Dry::CLI::Command
        desc 'Stress test CPU and GPU'

        def call(**)
          Assistant::Executor.async(
            stress_cpu_command,
            stress_gpu_command
          )

          Assistant::Executor.await
        end

        private

        def stress_cpu_command
          Assistant::Command.new(
            <<~BASH
              stress --cpu 16 --timeout 300
            BASH
          )
        end

        def stress_gpu_command
          Assistant::Command.new(
            <<~BASH
              hashcat -b
            BASH
          )
        end
      end
    end
  end
end
