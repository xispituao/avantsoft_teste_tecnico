class CreateFrames < ActiveRecord::Migration[8.0]
  def change
    create_table :frames do |t|
      t.decimal :x_axis, precision: 10, scale: 2
      t.decimal :y_axis, precision: 10, scale: 2
      t.decimal :width, precision: 10, scale: 2
      t.decimal :height, precision: 10, scale: 2
      t.decimal :highest_circle_position, precision: 10, scale: 2
      t.decimal :rightmost_circle_position, precision: 10, scale: 2
      t.decimal :leftmost_circle_position, precision: 10, scale: 2
      t.decimal :lowest_circle_position, precision: 10, scale: 2
      t.integer :circle_count, default: 0, null: false

      t.timestamps
    end

    # Índices para otimizar consultas de frames
    add_index :frames, [ :x_axis, :y_axis, :width, :height ], name: 'index_frames_on_geometry'

    # Índices compostos para consultas de sobreposição
    add_index :frames, [ :x_axis, :width ], name: 'index_frames_on_x_axis_width'
    add_index :frames, [ :y_axis, :height ], name: 'index_frames_on_y_axis_height'

    # Índice para counter_cache e ordenação
    add_index :frames, :circle_count
  end
end
