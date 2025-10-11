class CreateCircles < ActiveRecord::Migration[8.0]
  def change
    create_table :circles do |t|
      t.decimal :x_axis, precision: 10, scale: 2
      t.decimal :y_axis, precision: 10, scale: 2
      t.decimal :diameter, precision: 10, scale: 2
      t.references :frame, null: false, foreign_key: true

      t.timestamps
    end

    add_index :circles, [ :frame_id, :x_axis, :y_axis ], name: 'index_circles_on_frame_and_position'
    add_index :circles, [ :x_axis, :y_axis ], name: 'index_circles_on_position'
    add_index :circles, :diameter
  end
end
