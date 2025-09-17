FactoryBot.define do
  factory :circle do
    sequence(:x_axis) { |n| 50 + (n * 1000) }
    sequence(:y_axis) { |n| 50 + (n * 1000) }
    diameter { 20 }
    association :frame
  end
end
