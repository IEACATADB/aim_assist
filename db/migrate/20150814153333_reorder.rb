class Reorder < ActiveRecord::Migration
  def up
    change_column :champions, :mana_per_level, :float, :after => :mana
    change_column :champions, :key, :string, :after => :name
  end
  def down
  end
end
