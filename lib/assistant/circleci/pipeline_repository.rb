# frozen_string_literal: true

module Assistant
  module CircleCI
    class Pipeline
      attr_reader :id, :number, :created_at

      def initialize(data)
        @id = data['id']
        @number = data['number']
        @created_at = data['created_at']
      end
    end

    class PipelineRelation
      include Enumerable

      def initialize(pipelines)
        @pipelines = Array.new(pipelines)
      end

      def each
        for pipeline in @pipelines do
          yield pipeline
        end
      end

      def latest
        @pipelines.max_by { |pipeline| DateTime.parse(pipeline.created_at) }
      end
    end

    class PipelineRepository < BaseRepository
      # https://circleci.com/docs/api/v2/index.html#operation/listPipelinesForProject
      # PATH PARAMETERS
      #   - project-slug : (string) : Project slug in the form `vcs-slug/org-name/repo-name`
      # QUERY PARAMETERS
      #   - branch     : (string) : The name of a vcs branch
      #   - page-token : (string) : A token to retrieve the next page of results
      def get_by_project(project_slug:, query: {})
        response = self.class.get("/project/#{project_slug}/pipeline", query: query)
        response.success? ? on_success(response) : []
      end

      private

      def on_success(response)
        pipelines = JSON.parse(response.body)['items']

        PipelineRelation.new(
          pipelines.map do |pipeline|
            Pipeline.new(pipeline)
          end
        )
      rescue StandardError
        []
      end
    end
  end
end
