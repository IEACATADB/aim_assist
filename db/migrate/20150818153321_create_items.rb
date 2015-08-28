class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      
      t.string :name
      t.string :description
      t.float :cost
      t.float :FlatMPPoolMod
      t.float :FlatMagicDamageMod
      t.float :FlatCritChanceMod
      t.float :PercentAttackSpeedMod
      t.float :PercentMovementSpeedMod
      t.float :FlatArmorMod
      t.float :FlatMovementSpeedMod
      t.float :FlatHPPoolMod
      t.float :FlatPhysicalDamageMod
      t.float :PercentLifeStealMod
      t.float :FlatSpellBlockMod
      t.float :FlatHPRegenMod
      t.float :FlatMPRegenMod
      
    end
  end
end
