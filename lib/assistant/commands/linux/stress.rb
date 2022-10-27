# frozen_string_literal: true

module Assistant
  module Commands
    module Linux
      class Stress < Base
        desc 'Stress test CPU and GPU'

        def call(**)
          Assistant::Executor.instance.await do |async|
            async [
              stress_cpu_command,
              stress_gpu_command
            ]
          end
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
