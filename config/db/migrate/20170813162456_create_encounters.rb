class CreateEncounters < ActiveRecord::Migration[5.1]
  def change
    create_table :encounters do |t|
      t.integer :value

      t.timestamps
    end
  end
end
