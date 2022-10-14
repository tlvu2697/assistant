# frozen_string_literal: true

module Assistant
  module Commands
    module CircleCI
      class Approve < Dry::CLI::Command
        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)

        desc 'Approve CircleCI job'

        CIRLCECI_TOKEN_KEY = 'circleci_token'

        def call(**)
          @circleci_token = Assistant::Config.instance.prompt_fetch(CIRLCECI_TOKEN_KEY)
          @project_slug = yield fetch_project_slug
          @branch = yield fetch_branch

          pipeline = yield fetch_latest_pipeline
          workflows = yield fetch_workflows(pipeline_id: pipeline.id)
          jobs = yield fetch_available_jobs_of_workflows(workflows: workflows)

          prompt_select_jobs(jobs).each do |selected_job|
            approve_job(selected_job)
          end

          Success()
        end

        private

        def fetch_project_slug
          Assistant::Executor.instance.with_spinner(title: 'Getting project') do
            Success(
              Assistant::Executor.instance.capture(
                Assistant::Command.new(<<~BASH)
                  git remote get-url origin
                BASH
              ).to_a.first.gsub(/git@github.com:/, 'gh/').gsub(/.git/, '')
            )
          end
        end

        def fetch_branch
          Assistant::Executor.instance.with_spinner(title: 'Getting branch') do
            Success(
              Assistant::Executor.instance.capture(
                Assistant::Command.new(<<~BASH)
                  git rev-parse --abbrev-ref HEAD
                BASH
              ).to_a.first
            )
          end
        end

        def fetch_latest_pipeline
          Assistant::Executor.instance.with_spinner(title: 'Fetching latest pipeline') do
            pipeline_ = Assistant::CircleCI::PipelineRepository.new(
              circleci_token: @circleci_token
            ).get_latest_by_project(
              project_slug: @project_slug,
              query: { branch: @branch }
            )
            message = pipeline_.either(
              ->(pipeline) { "##{pipeline.number}" },
              ->(error_message) { error_message }
            )

            [pipeline_, message]
          end
        end

        def fetch_workflows(pipeline_id:)
          Assistant::Executor.instance.with_spinner(title: 'Fetching workflows') do
            workflows_ = Assistant::CircleCI::WorkflowRepository.new(
              circleci_token: @circleci_token
            ).get_by_pipeline(
              pipeline_id: pipeline_id
            )
            message = workflows_.either(
              ->(workflows) { workflows.map(&:name).join(', ') },
              ->(error_message) { error_message }
            )

            [workflows_, message]
          end
        end

        def fetch_available_jobs_of_workflows(workflows:)
          jobs_ = Assistant::CircleCI::JobRelation.none

          workflows.each do |workflow|
            jobs_ += fetch_jobs(workflow: workflow).value_or(Assistant::CircleCI::JobRelation.none)
          end

          jobs_.count.positive? ? Success(jobs_) : Failure('0 available job')
        end

        def fetch_jobs(workflow:)
          Assistant::Executor.instance.with_spinner(
            title: "Fetching jobs of workflow \"#{Assistant::PASTEL.green(workflow.name)}\""
          ) do
            jobs_ = Assistant::CircleCI::JobRepository.new(
              circleci_token: @circleci_token
            ).get_available_by_workflow(
              workflow_id: workflow.id
            )
            message = jobs_.either(
              ->(jobs) { jobs.map(&:name).join(', ') },
              ->(error_message) { error_message }
            )

            [jobs_, message]
          end
        end

        def prompt_select_jobs(jobs)
          indexed_jobs = jobs.each_with_object({}) { |job, hash| hash[job.name] = job }
          Assistant::PROMPT.multi_select('Select job to approve', indexed_jobs, cycle: true, min: 1)
        end

        def approve_job(job)
          Assistant::Executor.instance.with_spinner(
            title: "Approving job \"#{Assistant::PASTEL.green(job.name)}\""
          ) do
            Assistant::CircleCI::JobRepository.new(
              circleci_token: @circleci_token
            ).approve(
              workflow_id: job.workflow_id,
              job_approval_request_id: job.approval_request_id
            )
          end
        end
      end
    end
  end
end
