FactoryBot.define do

  sequence :name do |n|
    "List #{n}"
  end

  factory :list do
    name
    user
  end
end
