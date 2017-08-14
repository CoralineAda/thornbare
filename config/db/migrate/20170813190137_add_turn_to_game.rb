class AddTurnToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :turn, :integer
  end
end
