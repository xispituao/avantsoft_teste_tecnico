class FrameService
  def self.create_frame(params)
    # Converter circles para circles_attributes para nested_attributes
    if params[:circles].present?
      params[:circles_attributes] = params.delete(:circles)
    end
    
    frame = Frame.new(params)
    
    if frame.save
      { success: true, data: frame }
    else
      { success: false, errors: frame.errors.full_messages }
    end
  rescue ActiveRecord::RecordInvalid => e
    { success: false, errors: e.record.errors.full_messages }
  end

  def self.get_frame_details(frame)
    return { success: false, errors: [I18n.t('services.frame_service.errors.frame_not_found')] } unless frame
    
    # Calcular métricas dos círculos
    circles = frame.circles
    
    metrics = {
      total_circles: circles.count,
      highest_circle_position: circles.maximum(:y_axis),
      lowest_circle_position: circles.minimum(:y_axis),
      leftmost_circle_position: circles.minimum(:x_axis),
      rightmost_circle_position: circles.maximum(:x_axis)
    }
    
    { success: true, data: { frame: frame, metrics: metrics } }
  end

  def self.destroy_frame(frame)
    return { success: false, errors: [I18n.t('services.frame_service.errors.frame_not_found')] } unless frame
    
    if frame.circles.any?
      { success: false, errors: [I18n.t('services.frame_service.errors.cannot_delete_with_circles')] }
    else
      frame.destroy
      { success: true }
    end
  end
end
