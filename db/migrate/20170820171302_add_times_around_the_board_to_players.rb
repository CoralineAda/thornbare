class AddTimesAroundTheBoardToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :times_around_the_board, :integer, default: 0
  end
end
