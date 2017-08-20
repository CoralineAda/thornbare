class AddSuccessToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :success, :boolean, default: false
    add_column :players, :has_entered_sewers, :boolean, default: false
  end
end
