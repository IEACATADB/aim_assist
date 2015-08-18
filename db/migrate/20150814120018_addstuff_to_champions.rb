class AddstuffToChampions < ActiveRecord::Migration
  def change
    add_column :champions,:mana_per_level, :float
  end
end
