# frozen_string_literal: true

class CircleSerializer < ActiveModel::Serializer
  attributes :id, :x_axis, :y_axis, :diameter, :frame_id
end

