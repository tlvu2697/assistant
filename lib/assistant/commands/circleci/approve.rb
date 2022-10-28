# frozen_string_literal: true

module Assistant
  module Commands
    module CircleCI
      class Approve < Base
        desc 'Approve CircleCI jobs'

        def call(**)
          circleci_token

          @project_slug = yield fetch_project_slug
          @branch = yield fetch_branch

          pipeline = yield fetch_latest_pipeline
          workflows = yield fetch_workflows(pipeline_id: pipeline.id)
          jobs = yield fetch_on_hold_jobs_of_workflows(workflows: workflows)

          prompt_select_jobs(jobs).each do |selected_job|
            approve_job(selected_job)
          end

          Success()
        end

        private

        def fetch_latest_pipeline
          Assistant::Executor.instance.with_spinner(title: 'Fetching latest pipeline') do
            pipeline_ = pipeline_repository.get_latest_by_project(
              project_slug: @project_slug,
              query: { branch: @branch }
            )
            message = pipeline_.either(
              ->(pipeline) { "##{pipeline.number} - $#{pipeline.revision[0, 8]}" },
              ->(error_message) { error_message }
            )

            [pipeline_, message]
          end
        end

        def fetch_workflows(pipeline_id:)
          Assistant::Executor.instance.with_spinner(title: 'Fetching workflows') do
            workflows_ = workflow_repository.get_by_pipeline(
              pipeline_id: pipeline_id
            )
            message = workflows_.either(
              ->(workflows) { workflows.map(&:name).join(', ') },
              ->(error_message) { error_message }
            )

            [workflows_, message]
          end
        end

        def fetch_on_hold_jobs_of_workflows(workflows:)
          jobs_ = Assistant::CircleCI::JobRelation.none

          workflows.each do |workflow|
            jobs_ += fetch_jobs(workflow: workflow).value_or(Assistant::CircleCI::JobRelation.none)
          end

          jobs_.count.positive? ? Success(jobs_) : Failure('0 job')
        end

        def fetch_jobs(workflow:)
          Assistant::Executor.instance.with_spinner(
            title: "Fetching jobs of workflow \"#{Assistant::PASTEL.green(workflow.name)}\""
          ) do
            jobs_ = job_repository.get_on_hold_by_workflow(
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
          Assistant::PROMPT.multi_select(
            'Select job to approve',
            indexed_jobs,
            show_help: :always,
            cycle: true,
            min: 1
          )
        end

        def approve_job(job)
          Assistant::Executor.instance.with_spinner(
            title: "Approving job \"#{Assistant::PASTEL.green(job.name)}\""
          ) do
            job_repository.approve(
              workflow_id: job.workflow_id,
              job_approval_request_id: job.approval_request_id
            )
          end
        end
      end
    end
  end
end
