class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      
      t.text :description
      t.float :ad
      t.float :ap
      t.integer :total_cost
      t.integer :base_cost
      t.float :as
      t.float :lifesteal
      t.float :spellvamp
      t.float :arpen
      t.float :mrpen
      t.float :cdr
      t.float :mana
      t.float :hp
      t.float :mana5
      t.float :hp5
      t.float :msflat
      t.float :mspercent
      t.float :armor
      t.float :magres
      t.float :tenacity
      t.float :crit
      t.name :string
      t.timestamps null: true
    end
  end
end
