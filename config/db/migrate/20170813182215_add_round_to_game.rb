class AddRoundToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :round, :integer, default: 1
  end
end
