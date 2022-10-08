# frozen_string_literal: true

module Assistant
  module Commands
    module CircleCI
      class Approve < Dry::CLI::Command
        desc 'Approve CircleCI job'

        CIRLCECI_TOKEN_KEY = 'circleci_token'

        def call(**)
          @circleci_token = Assistant::Config.instance.prompt_fetch(CIRLCECI_TOKEN_KEY)

          project_slug
          branch

          pipeline = fetch_latest_pipeline
          workflows = fetch_workflows(pipeline_id: pipeline.id)

          jobs = Assistant::CircleCI::JobRelation.none
          workflows.each do |workflow|
            jobs += fetch_jobs(workflow: workflow)
          end

          approve_job(prompt_select_job(jobs.type_approval.status_on_hold))
        end

        private

        def project_slug
          @project_slug ||= Assistant::Executor.instance.sync(
            Assistant::Command.new(<<~BASH)
              git remote get-url origin
            BASH
          ).to_a.first.gsub(
            /git@github.com:/, 'gh/'
          ).gsub(/.git/, '')
        end

        def branch
          @branch ||= Assistant::Executor.instance.sync(
            Assistant::Command.new(<<~BASH)
              git rev-parse --abbrev-ref HEAD
            BASH
          ).to_a.first
        end

        def fetch_latest_pipeline
          Assistant.with_spinner(title: 'Fetching latest pipline') do
            repository = Assistant::CircleCI::PipelineRepository.new(circleci_token: @circleci_token)
            repository.get_by_project(
              project_slug: project_slug,
              query: { branch: branch }
            ).latest
          end
        end

        def fetch_workflows(pipeline_id:)
          Assistant.with_spinner(title: 'Fetching workflows') do
            repository = Assistant::CircleCI::WorkflowRepository.new(circleci_token: @circleci_token)
            repository.get_by_pipeline(pipeline_id: pipeline_id)
          end
        end

        def fetch_jobs(workflow:)
          Assistant.with_spinner(title: "Fetching jobs of workflow \"#{workflow.name}\"") do
            repository = Assistant::CircleCI::JobRepository.new(circleci_token: @circleci_token)
            repository.get_by_workflow(workflow_id: workflow.id)
          end
        end

        def prompt_select_job(jobs)
          indexed_jobs = jobs.each_with_object({}) { |job, hash| hash[job.name] = job }
          Assistant::PROMPT.select('Select job to approve', indexed_jobs, cycle: true)
        end

        def approve_job(job)
          Assistant.with_spinner(title: "Approving job \"#{job.name}\"") do
            repository = Assistant::CircleCI::JobRepository.new(circleci_token: @circleci_token)
            repository.approve(
              workflow_id: job.workflow_id,
              job_approval_request_id: job.approval_request_id
            )
          end
        end
      end
    end
  end
end
