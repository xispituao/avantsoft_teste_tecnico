class Frame < ApplicationRecord
  has_many :circles, dependent: :restrict_with_error
  accepts_nested_attributes_for :circles, allow_destroy: true, reject_if: :all_blank

  validates :x_axis, presence: true, numericality: true
  validates :y_axis, presence: true, numericality: true
  validates :width, presence: true, numericality: { greater_than: 0 }
  validates :height, presence: true, numericality: { greater_than: 0 }

  validate :no_frame_overlap

  def update_circle_positions!
    positions = circles.pluck(:x_axis, :y_axis)

    return reset_circle_positions! if positions.empty?

    x_positions = positions.map(&:first)
    y_positions = positions.map(&:last)

    update_columns(
      highest_circle_position: y_positions.min,
      lowest_circle_position: y_positions.max,
      leftmost_circle_position: x_positions.min,
      rightmost_circle_position: x_positions.max
    )
  end

  private

  def no_frame_overlap
    return unless x_axis && y_axis && width && height

    overlapping_frame = Frame
      .where.not(id: id)
      .where(
        "(x_axis + width >= ?::numeric AND x_axis <= ?::numeric + ?::numeric) AND (y_axis + height >= ?::numeric AND y_axis <= ?::numeric + ?::numeric)",
        x_axis, x_axis, width, y_axis, y_axis, height
      )
      .first

    if overlapping_frame
      errors.add(:base, I18n.t("activerecord.errors.models.frame.attributes.base.no_overlap"))
    end
  end

  def reset_circle_positions!
    update_columns(
      highest_circle_position: nil,
      lowest_circle_position: nil,
      leftmost_circle_position: nil,
      rightmost_circle_position: nil
    )
  end
end
