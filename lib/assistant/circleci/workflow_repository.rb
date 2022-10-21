# frozen_string_literal: true

module Assistant
  module CircleCI
    class Workflow
      attr_reader :id, :pipeline_id, :name, :status, :created_at

      def initialize(data)
        @id = data['id']
        @pipeline_id = data['pipeline_id']
        @name = data['name']
        @status = data['status']
        @created_at = data['created_at']
      end
    end

    class WorkflowRelation
      include Enumerable

      def self.none
        new([])
      end

      def initialize(workflows)
        @workflows = Array.new(workflows)
      end

      def each
        for workflow in @workflows do
          yield workflow
        end
      end

      def status_failing
        self.class.new(@workflows.filter { |w| w.status == 'failing' || w.status == 'failed' })
      end
    end

    class WorkflowRepository < BaseRepository
      include Dry::Monads[:result, :do]

      # https://circleci.com/docs/api/v2/index.html#operation/listWorkflowsByPipelineId
      # PATH PARAMETERS
      #   - pipeline-id : (string) : The unique ID of the pipeline
      # QUERY PARAMETERS
      #   - page-token : (string) : A token to retrieve the next page of results
      def get_by_pipeline(pipeline_id:, query: {})
        response = self.class.get("/pipeline/#{pipeline_id}/workflow", query: query)
        response.success? ? on_success(response) : on_fail
      end

      def get_failing_by_pipeline(pipeline_id:, query: {})
        workflows = yield get_by_pipeline(pipeline_id: pipeline_id, query: query)


        workflows = workflows.status_failing
        workflows.count.positive? ? Success(workflows) : on_fail
      end

      def rerun(workflow_id:)
        response = self.class.post(
          "/workflow/#{workflow_id}/rerun",
          body: {
            enable_ssh: false,
            from_failed: true,
            jobs: [],
            sparse_tree: false
          }.to_json
        )

        response.success? ? Success(response.message) : Failure(response.message)
      end

      private

      def on_success(response)
        workflows = JSON.parse(response.body)['items']

        Success(
          WorkflowRelation.new(
            workflows.map do |workflow|
              Workflow.new(workflow)
            end
          )
        )
      rescue StandardError
        on_fail
      end

      def on_fail
        Failure('0 workflow')
      end
    end
  end
end
