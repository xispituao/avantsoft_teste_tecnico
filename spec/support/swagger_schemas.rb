# frozen_string_literal: true

module SwaggerSchemas
  CIRCLE_RESPONSE = {
    type: :object,
    properties: {
      id: { type: :integer },
      frame_id: { type: :integer },
      x_axis: { type: :number },
      y_axis: { type: :number },
      diameter: { type: :number }
    },
    required: %w[id frame_id x_axis y_axis diameter]
  }.freeze

  CIRCLE_INPUT = {
    type: :object,
    properties: {
      circle: {
        type: :object,
        properties: {
          x_axis: { type: :number },
          y_axis: { type: :number },
          diameter: { type: :number }
        },
        required: %w[x_axis y_axis diameter]
      }
    }
  }.freeze

  CIRCLES_ARRAY = {
    type: :array,
    items: CIRCLE_RESPONSE
  }.freeze

  FRAME_RESPONSE = {
    type: :object,
    properties: {
      id: { type: :integer },
      x_axis: { type: :number },
      y_axis: { type: :number },
      width: { type: :number },
      height: { type: :number },
      circle_count: { type: :integer },
      highest_circle_position: { type: :number, nullable: true },
      lowest_circle_position: { type: :number, nullable: true },
      leftmost_circle_position: { type: :number, nullable: true },
      rightmost_circle_position: { type: :number, nullable: true }
    },
    required: %w[id x_axis y_axis width height circle_count]
  }.freeze

  FRAME_INPUT = {
    type: :object,
    properties: {
      frame: {
        type: :object,
        properties: {
          x_axis: { type: :number },
          y_axis: { type: :number },
          width: { type: :number },
          height: { type: :number },
          circles_attributes: {
            type: :array,
            items: {
              type: :object,
              properties: {
                x_axis: { type: :number },
                y_axis: { type: :number },
                diameter: { type: :number }
              }
            }
          }
        },
        required: %w[x_axis y_axis width height]
      }
    }
  }.freeze

  ERROR = {
    type: :object,
    properties: {
      error: { type: :string }
    },
    required: %w[error]
  }.freeze

  VALIDATION_ERRORS = {
    type: :object,
    properties: {
      errors: { type: :object }
    },
    required: %w[errors]
  }.freeze
end

