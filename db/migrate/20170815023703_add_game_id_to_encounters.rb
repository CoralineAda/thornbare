class AddGameIdToEncounters < ActiveRecord::Migration[5.1]
  def change
    add_column :encounters, :game_id, :integer
  end
end
