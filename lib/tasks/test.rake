namespace :groups do

  desc "Run all Groups"
  task run_tests: :environment do

    Group.all.each do |group|
      group.run_test
    end

  end
end