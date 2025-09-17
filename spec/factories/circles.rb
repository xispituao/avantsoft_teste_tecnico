FactoryBot.define do
  factory :circle do
    sequence(:x_axis) { |n| 50 + (n * 200) }
    sequence(:y_axis) { |n| 50 + (n * 200) }
    diameter { 20 }
    association :frame
  end
end
