class CreateChampions < ActiveRecord::Migration
  def change
    create_table :champions do |t|
      t.string :name
      t.string :key
      t.float :armor
      t.float :armorperlevel
      t.float :attackdamage
      t.float :attackdamageperlevel
      t.float :attackrange
      t.float :attackspeedoffset
      t.float :attackspeedperlevel
      t.float :crit
      t.float :critperlevel
      t.float :hp
      t.float :hpperlevel
      t.float :hpregen
      t.float :hpregenperlevel
      t.float :movespeed
      t.float :mp
      t.float :mpperlevel
      t.float :mpregen
      t.float :mpregenperlevel
      t.float :spellblock
      t.float :spellblockperlevel
    end
  end
end
