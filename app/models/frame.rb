class Frame < ApplicationRecord
  has_many :circles

  validates :x_axis, presence: true, numericality: true
  validates :y_axis, presence: true, numericality: true
  validates :width, presence: true, numericality: { greater_than: 0 }
  validates :height, presence: true, numericality: { greater_than: 0 }
  validates :total_circles, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :no_frame_overlap

  def no_frame_overlap
    return unless x_axis && y_axis && width && height

    # Buscar outros quadros
    other_frames = Frame.where.not(id: id)
    
    other_frames.each do |other_frame|
      # Verificar se os retângulos se intersectam ou encostam
      if rectangles_overlap_or_touch?(self, other_frame)
        errors.add(:base, "Quadro não pode tocar outro quadro")
        break
      end
    end
  end

  def rectangles_overlap_or_touch?(frame1, frame2)
    # Verificar se os retângulos se intersectam ou encostam
    # Dois retângulos se intersectam se:
    # - Um não está completamente à esquerda do outro
    # - Um não está completamente à direita do outro
    # - Um não está completamente acima do outro
    # - Um não está completamente abaixo do outro
    
    frame1_left = frame1.x_axis
    frame1_right = frame1.x_axis + frame1.width
    frame1_top = frame1.y_axis
    frame1_bottom = frame1.y_axis + frame1.height
    
    frame2_left = frame2.x_axis
    frame2_right = frame2.x_axis + frame2.width
    frame2_top = frame2.y_axis
    frame2_bottom = frame2.y_axis + frame2.height
    
    # Verificar sobreposição (incluindo encostar)
    # Dois retângulos se intersectam se NÃO há separação entre eles
    !(frame1_right < frame2_left || frame1_left > frame2_right ||
      frame1_bottom < frame2_top || frame1_top > frame2_bottom)
  end
end
