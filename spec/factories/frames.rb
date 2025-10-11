FactoryBot.define do
  factory :frame do
    x_axis { 0.0 }
    y_axis { 0.0 }
    width { 50.0 }
    height { 50.0 }

    trait :small do
      x_axis { 0.0 }
      y_axis { 0.0 }
      width { 10.0 }
      height { 10.0 }
    end

    trait :medium do
      x_axis { 0.0 }
      y_axis { 0.0 }
      width { 50.0 }
      height { 50.0 }
    end

    trait :large do
      x_axis { 0.0 }
      y_axis { 0.0 }
      width { 100.0 }
      height { 100.0 }
    end

    trait :with_circles do
      transient do
        circles_count { 3 }
      end

      after(:create) do |frame, evaluator|
        evaluator.circles_count.times do |i|
          create(:circle,
            frame: frame,
            x_axis: frame.x_axis + 10 + (i * 15),
            y_axis: frame.y_axis + 10 + (i * 15),
            diameter: 5.0
          )
        end
      end
    end
  end
end
