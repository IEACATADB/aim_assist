class CreateChampions < ActiveRecord::Migration
  def change
    create_table :champions do |t|
      t.string :name
      t.float :armor,:armor_per_level,:ad,:ad_per_level,:range, :as_offset, :as_per_level,
      :hp,:hp_per_lvl ,:hp5,:hp5_per_level,:mana,:mana5,:mana5_per_level,:msflat,:magres,:magres_per_level
      t.timestamps null: false
    end
  end
end
