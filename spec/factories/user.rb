FactoryBot.define do

  sequence :email do |n|
    "example#{n}@mail.com"
  end

  factory :user do
    first_name { 'John' }
    last_name { 'Doe' }
    email
    password  { 'This_Is_A_Basic_P4ssword' }
    password_confirmation { 'This_Is_A_Basic_P4ssword' }
  end
end
