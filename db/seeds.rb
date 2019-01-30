# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#Create an Admin
admin = User.where(email: 'admin@test.com').first_or_create do |user|
  user.password = 'welcome1'
  user.password_confirmation = 'welcome1'
  user.first_name = "Delete"
  user.last_name = "Me"
  puts 'Creating Default Admin User (Change these settings)'
  puts 'email: ' + user.email
  puts 'password: '+ 'welcome1'
end

# Create test Counties
Location.where(category: 1).destroy_all
counties = ['Bronx County', 'Kings County', 'New York County', 'Queens County', 'Richmond County']
counties.each { |county|
	location = Location.new
	location.category = 1
	location.name = county
	location.save
}
indexes = Location.where(category: 1).pluck(:id)
combos = indexes.combination(2).to_a

# Create test Plans
Plan.all.destroy_all
PlanLocation.all.destroy_all

('2018-11-01'.to_datetime.to_i .. '2019-02-15'.to_datetime.to_i).step(1.hour) do |d|
	rand(40).times do |n|
		plan = Plan.new
		plan.request_time = Time.at(d)
		plan.server_time = Time.at(d)
		plan.save

		combo = combos[rand(0..4)]
		plan.plan_location = PlanLocation.new
		plan.plan_location.category_id = 1
		plan.plan_location.from_category_id = combo[0]
		plan.plan_location.to_category_id = combo[1]
		plan.plan_location.save
	end
end

