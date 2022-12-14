# frozen_string_literal: true

module Assistant
  module CircleCI
    class Job
      attr_reader :id, :approval_request_id, :workflow_id, :name, :type, :status, :tag

      def initialize(data)
        @id = data['id']
        @approval_request_id = data['approval_request_id']
        @workflow_id = data['workflow_id']
        @name = data['name']
        @type = data['type']
        @status = data['status']
        @tag = "#{name}##{id.split("-").first}"
      end
    end

    class JobRelation
      include Enumerable

      attr_accessor :jobs

      def self.none
        new([])
      end

      def initialize(jobs)
        @jobs = Array.new(jobs)
      end

      def each
        for job in @jobs do
          yield job
        end
      end

      def +(other)
        jobs_ = other.respond_to?(:jobs) ? @jobs + other.jobs : @jobs + other
        self.class.new(jobs_)
      end

      def flatten!
        @jobs.flatten!
      end

      def reverse
        @jobs.reverse
      end

      def type_approval
        self.class.new(@jobs.filter { |job| job.type == 'approval' })
      end

      def status_on_hold
        self.class.new(@jobs.filter { |job| job.status == 'on_hold' })
      end

      def status_success
        self.class.new(@jobs.filter { |job| job.status == 'success' })
      end
    end

    class JobRepository < BaseRepository
      include Dry::Monads[:result, :do]

      # https://circleci.com/docs/api/v2/index.html#operation/listWorkflowJobs
      # PATH PARAMETERS
      #   - workflow-id : (string) : The unique ID of the workflow
      def get_by_workflow(workflow_id:)
        response = self.class.get("/workflow/#{workflow_id}/job")
        response.success? ? on_success(response, { 'workflow_id' => workflow_id }) : on_fail
      end

      def get_on_hold_by_workflow(workflow_id:)
        jobs = yield get_by_workflow(workflow_id: workflow_id)

        jobs = jobs.type_approval.status_on_hold
        jobs.count.positive? ? Success(jobs) : on_fail
      end

      def approve(workflow_id:, job_approval_request_id:)
        response = self.class.post(
          "/workflow/#{workflow_id}/approve/#{job_approval_request_id}"
        )
        message = JSON.parse(response.body)['message']
        response.success? ? Success(message) : Failure(message)
      end

      private

      def on_success(response, options = {})
        jobs = JSON.parse(response.body)['items']

        Success(
          JobRelation.new(
            jobs.map do |job|
              Job.new(job.merge(options))
            end
          )
        )
      rescue StandardError
        on_fail
      end

      def on_fail
        Failure('0 job')
      end
    end
  end
end
