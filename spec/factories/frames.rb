FactoryBot.define do
  factory :frame do
    sequence(:x_axis) { |n| n * 200 }
    sequence(:y_axis) { |n| n * 200 }
    width { 100 }
    height { 100 }
    total_circles { 0 }
    highest_circle_position { nil }
    rightmost_circle_position { nil }
    leftmost_circle_position { nil }
    lowest_circle_position { nil }
  end
end
