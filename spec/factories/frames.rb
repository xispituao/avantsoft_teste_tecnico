FactoryBot.define do
  factory :frame do
    # Simple defaults - tests should specify explicit values
    x_axis { 0.0 }
    y_axis { 0.0 }
    width { 50.0 }
    height { 50.0 }

    # Factory with specific dimensions for predictable testing
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

    # Factory with circles - explicitly positioned to avoid overlap
    trait :with_circles do
      transient do
        circles_count { 3 }
      end

      after(:create) do |frame, evaluator|
        evaluator.circles_count.times do |i|
          # Create circles in a grid pattern with explicit coordinates
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

