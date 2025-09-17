class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # Índices para otimizar consultas geométricas
    add_index :circles, [:frame_id, :x_axis, :y_axis], name: 'index_circles_on_frame_and_position'
    add_index :circles, [:x_axis, :y_axis], name: 'index_circles_on_position'
    
    # Índices para otimizar consultas de frames
    add_index :frames, [:x_axis, :y_axis, :width, :height], name: 'index_frames_on_geometry'
    
    # Índices compostos para consultas de sobreposição
    add_index :frames, [:x_axis, :width], name: 'index_frames_on_x_axis_width'
    add_index :frames, [:y_axis, :height], name: 'index_frames_on_y_axis_height'
  end
end