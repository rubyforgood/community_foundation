# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

arlington = Organization.find_or_create_by!(subdomain: "arlington") do |org|
  org.name = "Arlington Community Foundation"
  org.website = "https://www.arlcf.org/"
end

unless arlington.logo.attached?
  logo_path = Rails.root.join("db/seed_assets/arlington-logo.png")
  arlington.logo.attach(io: File.open(logo_path), filename: "arlington-logo.png", content_type: "image/png")
end

# One user per role, all members of arlington.
%i[ owner admin member ].each do |role|
  user = User.find_or_initialize_by(email_address: "#{role}@example.com")
  user.password = "password"
  user.confirmed_at = Time.current
  user.save!

  membership = OrganizationMembership.find_or_create_by!(user: user, organization: arlington)
  membership.update!(role: role)
end

owner = User.find_by!(email_address: "owner@example.com")

balanced = owner.scenarios.find_or_create_by!(organization: arlington, name: "Balanced giving") do |scenario|
  scenario.total_giving_amount = 10_000
end

if balanced.allocations.empty?
  balanced.ongoing_allocations.create!(option: "Greatest Community Need", percentage: 30)
  balanced.ongoing_allocations.create!(option: "Program: Education", percentage: 30)
  balanced.ongoing_allocations.create!(option: "Population: Youth", percentage: 40)
  balanced.one_time_allocations.create!(option: "Specific org", amount: 1_000)
end

education = owner.scenarios.find_or_create_by!(organization: arlington, name: "Education focus") do |scenario|
  scenario.total_giving_amount = 5_000
end

if education.allocations.empty?
  education.ongoing_allocations.create!(option: "Program: Education", percentage: 60)
  education.ongoing_allocations.create!(option: "Population: Youth (5–21)", percentage: 25)
  education.ongoing_allocations.create!(option: "Greatest Community Need", percentage: 15)
  education.one_time_allocations.create!(option: "Scholarship Fund", amount: 500)
end
