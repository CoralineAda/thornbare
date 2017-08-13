class CreateResources < ActiveRecord::Migration[5.1]
  def change
    create_table :resources do |t|
      t.integer :value
      t.references :player
      t.timestamps
    end
  end
end
