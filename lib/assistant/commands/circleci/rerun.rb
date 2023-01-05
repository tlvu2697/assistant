# frozen_string_literal: true

module Assistant
  module Commands
    module CircleCI
      class Rerun < Base
        desc 'Rerun CircleCI workflows'

        def call(**)
          circleci_token

          @project_slug = yield fetch_project_slug
          @branch = yield fetch_branch

          pipeline = yield fetch_latest_pipeline
          workflows = yield fetch_failing_workflows(pipeline_id: pipeline.id)

          prompt_select_workflows(workflows).each do |selected_workflow|
            cancel_workflow(selected_workflow)
            rerun_workflow(selected_workflow)
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

        def fetch_failing_workflows(pipeline_id:)
          Assistant::Executor.instance.with_spinner(title: 'Fetching workflows') do
            workflows_ = workflow_repository.get_failing_by_pipeline(
              pipeline_id: pipeline_id
            )
            message = workflows_.either(
              ->(workflows) { workflows.map(&:name).join(', ') },
              ->(error_message) { error_message }
            )

            [workflows_, message]
          end
        end

        def prompt_select_workflows(workflows)
          indexed_workflows = workflows.reverse.each_with_object({}) { |workflow, hash| hash[workflow.name] = workflow }
          Assistant::PROMPT.multi_select(
            'Select workflow to rerun',
            indexed_workflows,
            show_help: :always,
            cycle: true,
            min: 1
          )
        end

        def cancel_workflow(workflow)
          Assistant::Executor.instance.with_spinner(
            title: "Canceling workflow \"#{Assistant::PASTEL.green(workflow.name)}\""
          ) do
            workflow_repository.cancel(workflow_id: workflow.id)
          end
        end

        def rerun_workflow(workflow)
          Assistant::Executor.instance.with_spinner(
            title: "Re-running workflow \"#{Assistant::PASTEL.green(workflow.tag)}\""
          ) do
            workflow_repository.rerun(workflow_id: workflow.id)
          end
        end
      end
    end
  end
end
