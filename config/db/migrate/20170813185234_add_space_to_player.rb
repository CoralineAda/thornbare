class AddSpaceToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :position, :integer, default: 0
  end
end
