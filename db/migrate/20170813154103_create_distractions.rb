class CreateDistractions < ActiveRecord::Migration[5.1]
  def change
    create_table :distractions do |t|
      t.integer :value
      t.references :player
      t.timestamps
    end
  end
end
