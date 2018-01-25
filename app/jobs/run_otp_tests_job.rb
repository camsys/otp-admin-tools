class RunOtpTestsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # No args passed, run all the groups
    if args.empty?
      Group.all.each do |group|
        group.run_otp_test
      end

    # If an ID is passed, run only that group
    else
      Group.find(args.first).run_otp_test
    end

  end
end
