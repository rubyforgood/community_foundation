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

# These were provided by Arlington Community Foundation
ALLOCATION_CATEGORIES = {
  "AllocationCategory::Program" => {
    "Arts & Culture" => [],
    "Education" => [
      "Early Childhood Education", "Primary & Secondary Education",
      "Higher Education", "Vocational & Technical Education", "Other Education"
    ],
    "Environment" => [],
    "Animal-Related" => [],
    "Health Care" => [
      "Traditional Health Care", "Mental Health",
      "Diseases, Disorders & Medical Disciplines", "Medical Research"
    ],
    "Crime & Legal-Related" => [],
    "Basic Needs" => [ "Employment", "Food and Nutrition", "Housing & Shelter", "Human Services" ],
    "Public Safety, Disaster Preparedness and Relief" => [],
    "Recreation and Sports" => [],
    "International and Foreign Affairs" => [],
    "Civil Rights & Social Action" => [],
    "Community Improvement & Capacity Building" => [],
    "Philanthropy & Voluntarism" => [],
    "Religion & Spirituality" => []
  },
  "AllocationCategory::Population" => {
    "Children and Youth" => [], "Elderly" => [], "BIPOC" => [], "Disabled" => [],
    "LGBTQIA+" => [], "Low-Income" => [], "Unhoused" => [], "Veterans" => [],
    "Women" => [], "Immigrants" => [], "Formerly Incarcerated" => []
  }
}.freeze

ALLOCATION_CATEGORIES.each do |type, roots|
  roots.each do |root_name, child_names|
    root = arlington.allocation_categories.find_or_create_by!(type: type, name: root_name, parent: nil)
    child_names.each do |child_name|
      arlington.allocation_categories.find_or_create_by!(type: type, name: child_name, parent: root)
    end
  end
end

education_category = arlington.allocation_categories.find_by!(name: "Education")
youth_category = arlington.allocation_categories.find_by!(name: "Children and Youth")

owner = User.find_by!(email_address: "owner@example.com")

balanced = owner.scenarios.find_or_create_by!(organization: arlington, name: "Balanced giving") do |scenario|
  scenario.total_giving_amount = 10_000
end

if balanced.allocations.empty?
  balanced.ongoing_allocations.create!(allocation_category: education_category, percentage: 30)
  balanced.ongoing_allocations.create!(allocation_category: youth_category, percentage: 40)
  # Demonstrates the free-text fallback for needs without a curated category.
  balanced.ongoing_allocations.create!(option: "Greatest Community Need", percentage: 30)
  balanced.one_time_allocations.create!(option: "Specific org", amount: 1_000)
end

education = owner.scenarios.find_or_create_by!(organization: arlington, name: "Education focus") do |scenario|
  scenario.total_giving_amount = 5_000
end

if education.allocations.empty?
  education.ongoing_allocations.create!(allocation_category: education_category, percentage: 60)
  education.ongoing_allocations.create!(allocation_category: youth_category, percentage: 25)
  education.ongoing_allocations.create!(option: "Greatest Community Need", percentage: 15)
  education.one_time_allocations.create!(option: "Scholarship Fund", amount: 500)
end

scenario_themes = [
  "Arts & culture", "Climate resilience", "Food security", "Housing first",
  "Youth mentorship", "Scholarships", "Health access", "Workforce training",
  "Digital literacy", "Senior services", "Disaster relief", "Refugee support",
  "Environmental fund", "Clean water", "Mental health", "Crisis hotline",
  "Community garden", "Neighborhood grants", "Small org boost", "Arts education"
]

12.times do
  display_name = Faker::Name.unique.name
  email = "#{display_name.parameterize}@example.com"

  user = User.find_or_initialize_by(email_address: email)
  user.name = display_name
  user.password = "password"
  user.confirmed_at = Time.current
  user.save!

  OrganizationMembership.find_or_create_by!(user: user, organization: arlington) do |membership|
    membership.role = :member
  end

  scenario_themes.sample(rand(1..3)).each do |name|
    user.scenarios.find_or_create_by!(organization: arlington, name: name) do |scenario|
      scenario.total_giving_amount = rand(1..40) * 1_000
    end
  end
end
