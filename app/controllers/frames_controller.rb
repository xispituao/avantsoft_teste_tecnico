# frozen_string_literal: true

class FramesController < ApplicationController
  before_action :set_frame, only: %i[show destroy]

  # POST /frames
  def create
    @frame = Frame.new(frame_params)

    if @frame.save
      render json: @frame, status: :created
    else
      render json: { errors: @frame.errors }, status: :unprocessable_entity
    end
  end

  # GET /frames/:i
  def show
    render json: {
      id: @frame.id,
      x_axis: @frame.x_axis,
      y_axis: @frame.y_axis,
      width: @frame.width,
      height: @frame.height,
      circle_count: @frame.circle_count,
      highest_circle_position: @frame.highest_circle_position,
      lowest_circle_position: @frame.lowest_circle_position,
      leftmost_circle_position: @frame.leftmost_circle_position,
      rightmost_circle_position: @frame.rightmost_circle_position
    }
  end

  # DELETE /frames/:id
  def destroy
    if @frame.circles.any?
      render json: { error: "Cannot delete frame with circles" }, status: :unprocessable_entity
    else
      @frame.destroy
      head :no_content
    end
  end

  private

  def set_frame
    @frame = Frame.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def frame_params
    params.require(:frame).permit(
      :x_axis, :y_axis, :width, :height,
      circles_attributes: %i[x_axis y_axis diameter]
    )
  end
end
