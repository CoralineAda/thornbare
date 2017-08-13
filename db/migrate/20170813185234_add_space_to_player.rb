class AddSpaceToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :space, :integer, default: 1
  end
end
