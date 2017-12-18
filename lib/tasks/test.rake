namespace :groups do

  desc "Run all Groups"
  task run_tests: :environment do
    Group.all.each do |group|
      group.run_test
    end
  end
end

namespace :email do

  desc "Check Email"
  task create_trips: :environment do
    MailService.new.create_trips
  end

end