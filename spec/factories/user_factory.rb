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

    factory :user_with_lists do
      transient do
        lists_count { 2 }
      end

      lists do
        Array.new(lists_count) { association :list }
      end
    end
  end
end
