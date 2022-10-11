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
            yield approve_job(selected_job)
          end

          Success()
        end

        private

        def fetch_project_slug
          project_slug_ = nil
          Assistant::SPINNER.update(title: 'Getting project')
          Assistant::SPINNER.run do |spinner|
            begin
              project_slug_ = Success(Assistant::Executor.instance.capture(
                Assistant::Command.new(<<~BASH)
                  git remote get-url origin
                BASH
              ).to_a.first.gsub(/git@github.com:/, 'gh/').gsub(/.git/, ''))

              spinner.success(Assistant::Utils.format_spinner_success(project_slug_.value!))
            rescue StandardError => e
              project_slug_ = Failure(e.message)

              spinner.error(Assistant::Utils.format_spinner_error(project_slug_.failure))
            end
          end
          project_slug_
        end

        def fetch_branch
          branch_ = nil
          Assistant::SPINNER.update(title: 'Getting branch')
          Assistant::SPINNER.run do |spinner|
            begin
              branch_ = Success(Assistant::Executor.instance.capture(
                Assistant::Command.new(<<~BASH)
                  git rev-parse --abbrev-ref HEAD
                BASH
              ).to_a.first)

              spinner.success(Assistant::Utils.format_spinner_success(branch_.value!))
            rescue StandardError => e
              branch_ = Failure(e.message)

              spinner.error(Assistant::Utils.format_spinner_error(branch_.failure))
            end
          end
          branch_
        end

        def fetch_latest_pipeline
          pipeline_ = nil
          Assistant::SPINNER.update(title: 'Fetching latest pipline')
          Assistant::SPINNER.run do |spinner|
            begin
              pipeline_ = Assistant::CircleCI::PipelineRepository
                          .new(circleci_token: @circleci_token)
                          .get_latest_by_project(project_slug: @project_slug, query: { branch: @branch })

              if pipeline_.success?
                spinner.success(Assistant::Utils.format_spinner_success("##{pipeline_.value!.number}"))
              else
                spinner.error(Assistant::Utils.format_spinner_error(pipeline_.failure))
              end
            rescue StandardError => e
              pipeline_ = Failure(e.message)

              spinner.error(Assistant::Utils.format_spinner_error(pipeline_.failure))
            end
          end
          pipeline_
        end

        def fetch_workflows(pipeline_id:)
          workflows_ = nil
          Assistant::SPINNER.update(title: 'Fetching workflows')
          Assistant::SPINNER.run do |spinner|
            begin
              workflows_ = Assistant::CircleCI::WorkflowRepository
                           .new(circleci_token: @circleci_token)
                           .get_by_pipeline(pipeline_id: pipeline_id)

              if workflows_.success?
                spinner.success(Assistant::Utils.format_spinner_success(workflows_.value!.map(&:name).join(', ')))
              else
                spinner.error(Assistant::Utils.format_spinner_error(workflows_.failure))
              end
            rescue StandardError => e
              workflows_ = Failure(e.message)

              spinner.error(Assistant::Utils.format_spinner_error(workflows_.failure))
            end
          end
          workflows_
        end

        def fetch_available_jobs_of_workflows(workflows:)
          jobs_ = Assistant::CircleCI::JobRelation.none

          workflows.each do |workflow|
            jobs_ += fetch_jobs(workflow: workflow).value_or(Assistant::CircleCI::JobRelation.none)
          end

          jobs_.count.positive? ? Success(jobs_) : Failure('0 available job')
        end

        def fetch_jobs(workflow:)
          jobs_ = nil
          Assistant::SPINNER.update(title: "Fetching jobs of workflow \"#{Assistant::PASTEL.green(workflow.name)}\"")
          Assistant::SPINNER.run do |spinner|
            begin
              jobs_ = Assistant::CircleCI::JobRepository
                      .new(circleci_token: @circleci_token)
                      .get_available_by_workflow(workflow_id: workflow.id)

              if jobs_.success?
                spinner.success(Assistant::Utils.format_spinner_success(jobs_.value!.map(&:name).join(', ')))
              else
                spinner.error(Assistant::Utils.format_spinner_error(jobs_.failure))
              end
            rescue StandardError => e
              jobs_ = Failure(e.message)

              spinner.error(Assistant::Utils.format_spinner_error(jobs_.failure))
            end
          end
          jobs_
        end

        def prompt_select_jobs(jobs)
          indexed_jobs = jobs.each_with_object({}) { |job, hash| hash[job.name] = job }
          Assistant::PROMPT.multi_select('Select job to approve', indexed_jobs, cycle: true)
        end

        def approve_job(job)
          result_ = nil
          Assistant::SPINNER.update(title: "Approving job \"#{Assistant::PASTEL.green(job.name)}\"")
          Assistant::SPINNER.run do |spinner|
            begin
              result_ = Assistant::CircleCI::JobRepository
                        .new(circleci_token: @circleci_token)
                        .approve(
                          workflow_id: job.workflow_id,
                          job_approval_request_id: job.approval_request_id
                        )

              if result_.success?
                spinner.success(Assistant::Utils.format_spinner_success(result_.value!))
              else
                spinner.error(Assistant::Utils.format_spinner_error(result_.failure))
              end
            rescue StandardError => e
              result_ = Failure(e.message)

              spinner.error(Assistant::Utils.format_spinner_error(result_.failure))
            end
          end
        end
      end
    end
  end
end
