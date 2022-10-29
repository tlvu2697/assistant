# frozen_string_literal: true

module Assistant
  module Commands
    module CircleCI
      class Base < Dry::CLI::Command
        include Dry::Monads[:result, :do]

        private

        def circleci_token
          @circleci_token ||= Assistant::Config.instance.prompt_fetch(
            Assistant::Config::CIRLCECI_TOKEN_KEY,
            hint: 'https://app.circleci.com/settings/user/tokens'
          )
        end

        def pipeline_repository
          @pipeline_repository ||= Assistant::CircleCI::PipelineRepository.new(
            circleci_token: circleci_token
          )
        end

        def workflow_repository
          @workflow_repository ||= Assistant::CircleCI::WorkflowRepository.new(
            circleci_token: circleci_token
          )
        end

        def job_repository
          @job_repository ||= Assistant::CircleCI::JobRepository.new(
            circleci_token: circleci_token
          )
        end

        def fetch_project_slug
          Assistant::Executor.instance.with_spinner(title: 'Fetching project') do
            Success(
              Assistant::Executor.instance.capture(
                Assistant::Models::Command.new(<<~BASH)
                  git remote get-url origin
                BASH
              ).first.gsub(/git@github.com:/, 'gh/').gsub(/.git/, '')
            )
          end
        end

        def fetch_branch
          Assistant::Executor.instance.with_spinner(title: 'Fetching branch') do
            Success(
              Assistant::Executor.instance.capture(
                Assistant::Models::Command.new(<<~BASH)
                  git rev-parse --abbrev-ref HEAD
                BASH
              ).first
            )
          end
        end
      end
    end
  end
end
