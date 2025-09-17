class Api::V1::FramesController < ApplicationController
  before_action :set_frame, only: [:show, :destroy, :circles]

  # POST /api/v1/frames
  def create
    result = FrameService.create_frame(frame_params)
    
    if result[:success]
      render json: result[:data], serializer: FrameSerializer, status: :created
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/frames/:id
  def show
    result = FrameService.get_frame_details(@frame)
    
    if result[:success]
      frame_data = FrameSerializer.new(result[:data][:frame]).as_json
      frame_data[:metrics] = result[:data][:metrics]
      render json: frame_data, status: :ok
    else
      render json: { errors: result[:errors] }, status: :not_found
    end
  end

  # DELETE /api/v1/frames/:id
  def destroy
    result = FrameService.destroy_frame(@frame)
    
    if result[:success]
      head :no_content
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/frames/:id/circles
  def circles
    result = CircleService.create_circle(@frame, circle_params)
    
    if result[:success]
      render json: result[:data], serializer: CircleSerializer, status: :created
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  private

  def set_frame
    @frame = Frame.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: [I18n.t('controllers.frames.errors.frame_not_found')] }, status: :not_found
  end

  def frame_params
    params.require(:frame).permit(:x_axis, :y_axis, :width, :height, 
                                  circles_attributes: [:x_axis, :y_axis, :diameter, :_destroy, :id])
  end

  def circle_params
    params.require(:circle).permit(:x_axis, :y_axis, :diameter)
  end
end
