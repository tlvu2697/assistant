# frozen_string_literal: true

module Assistant
  module CircleCI
    class Workflow
      attr_reader :id, :pipeline_id, :name, :created_at

      def initialize(data)
        @id = data['id']
        @pipeline_id = data['pipeline_id']
        @name = data['name']
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
    end

    class WorkflowRepository < BaseRepository
      include Dry::Monads[:result]

      # https://circleci.com/docs/api/v2/index.html#operation/listWorkflowsByPipelineId
      # PATH PARAMETERS
      #   - pipeline-id : (string) : The unique ID of the pipeline
      # QUERY PARAMETERS
      #   - page-token : (string) : A token to retrieve the next page of results
      def get_by_pipeline(pipeline_id:, query: {})
        response = self.class.get("/pipeline/#{pipeline_id}/workflow", query: query)
        response.success? ? on_success(response) : on_fail
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
        Failure('0 available workflow')
      end
    end
  end
end
