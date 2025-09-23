class Api::V1::CirclesController < ApplicationController
  before_action :set_circle, only: [ :update, :destroy ]

  # GET /api/v1/circles
  def index
    result = CircleService.search_circles(search_params)

    if result[:success]
      render json: result[:data], each_serializer: CircleSerializer, status: :ok
    else
      render json: { errors: result[:errors] }, status: :unprocessable_content
    end
  end

  # PUT /api/v1/circles/:id
  def update
    result = CircleService.update_circle(@circle, circle_params)

    if result[:success]
      render json: result[:data], serializer: CircleSerializer, status: :ok
    else
      render json: { errors: result[:errors] }, status: :unprocessable_content
    end
  end

  # DELETE /api/v1/circles/:id
  def destroy
    result = CircleService.destroy_circle(@circle)

    if result[:success]
      head :no_content
    else
      render json: { errors: result[:errors] }, status: :not_found
    end
  end

  private

  def set_circle
    @circle = Circle.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: [ I18n.t("controllers.circles.errors.circle_not_found") ] }, status: :not_found
  end

  def circle_params
    params.require(:circle).permit(:x_axis, :y_axis, :diameter)
  end

  def search_params
    params.permit(:center_x, :center_y, :radius, :frame_id)
  end
end
