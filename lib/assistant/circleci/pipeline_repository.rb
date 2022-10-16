# frozen_string_literal: true

module Assistant
  module CircleCI
    class Pipeline
      attr_reader :id, :number, :revision, :created_at

      def initialize(data)
        @id = data['id']
        @number = data['number']
        @revision = data.dig('vcs', 'revision')
        @created_at = data['created_at']
      end
    end

    class PipelineRelation
      include Enumerable

      def self.none
        new([])
      end

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
      include Dry::Monads[:result, :do]

      # https://circleci.com/docs/api/v2/index.html#operation/listPipelinesForProject
      # PATH PARAMETERS
      #   - project-slug : (string) : Project slug in the form `vcs-slug/org-name/repo-name`
      # QUERY PARAMETERS
      #   - branch     : (string) : The name of a vcs branch
      #   - page-token : (string) : A token to retrieve the next page of results
      def get_by_project(project_slug:, query: {})
        response = self.class.get("/project/#{project_slug}/pipeline", query: query)
        response.success? ? on_success(response) : on_fail
      end

      def get_latest_by_project(project_slug:, query: {})
        pipelines = yield get_by_project(project_slug: project_slug, query: query)

        latest_pipeline = pipelines.latest
        latest_pipeline.nil? ? on_fail : Success(latest_pipeline)
      end

      private

      def on_success(response)
        pipelines = JSON.parse(response.body)['items']

        Success(
          PipelineRelation.new(
            pipelines.map do |pipeline|
              Pipeline.new(pipeline)
            end
          )
        )
      rescue StandardError
        on_fail
      end

      def on_fail
        Failure('0 available pipeline')
      end
    end
  end
end
