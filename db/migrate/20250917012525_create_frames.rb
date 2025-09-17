class CreateFrames < ActiveRecord::Migration[8.0]
  def change
    create_table :frames do |t|
      t.decimal :x_axis, precision: 10, scale: 2
      t.decimal :y_axis, precision: 10, scale: 2
      t.decimal :width, precision: 10, scale: 2
      t.decimal :height, precision: 10, scale: 2
      t.integer :total_circles, default: 0
      t.decimal :highest_circle_position, precision: 10, scale: 2
      t.decimal :rightmost_circle_position, precision: 10, scale: 2
      t.decimal :leftmost_circle_position, precision: 10, scale: 2
      t.decimal :lowest_circle_position, precision: 10, scale: 2

      t.timestamps
    end
  end
end
