class Circle < ApplicationRecord
  belongs_to :frame, counter_cache: :circles_count

  validates :x_axis, presence: true, numericality: true
  validates :y_axis, presence: true, numericality: true
  validates :diameter, presence: true, numericality: { greater_than: 0 }
  validates :frame, presence: true

  validate :circle_fits_in_frame
  validate :no_circle_overlap

  def circle_fits_in_frame
    return unless frame && x_axis && y_axis && diameter

    radius = diameter / 2.0
    
    # Verificar se o círculo cabe dentro do quadro
    if x_axis - radius < frame.x_axis ||
       x_axis + radius > frame.x_axis + frame.width ||
       y_axis - radius < frame.y_axis ||
       y_axis + radius > frame.y_axis + frame.height
      errors.add(:base, I18n.t('models.circle.errors.circle_fits_in_frame'))
    end
  end

  def no_circle_overlap
    return unless frame && x_axis && y_axis && diameter

    # Buscar outros círculos no mesmo quadro
    other_circles = frame.circles.where.not(id: id)
    
    other_circles.each do |other_circle|
      distance = Math.sqrt((x_axis - other_circle.x_axis)**2 + (y_axis - other_circle.y_axis)**2)
      min_distance = (diameter + other_circle.diameter) / 2.0
      
      # Círculos se tocam se a distância entre centros é menor ou igual à soma dos raios
      if distance <= min_distance
        errors.add(:base, I18n.t('models.circle.errors.no_circle_overlap'))
        break
      end
    end
  end
end
