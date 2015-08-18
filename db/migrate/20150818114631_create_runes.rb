class CreateRunes < ActiveRecord::Migration
  def change
    create_table :runes do |t|
      t.float :FlatMagicDamageMod
      t.float :rPercentCooldownModPerLevel
      t.float :rPercentCooldownMod
      t.float :rFlatEnergyRegenModPerLevel
      t.float :rFlatHPRegenModPerLevel
      t.float :PercentMovementSpeedMod
      t.float :FlatEnergyPoolMod
      t.float :FlatHPPoolMod
      t.float :FlatEnergyRegenMod
      t.float :rFlatEnergyModPerLevel
      t.float :rFlatMagicPenetrationMod
      t.float :rFlatArmorPenetrationMod
      t.float :PercentEXPBonus
      t.float :FlatCritDamageMod
      t.float :FlatHPRegenMod
      t.float :FlatSpellBlockMod
      t.float :rFlatSpellBlockModPerLevel
      t.float :FlatArmorMod
      t.float :rFlatArmorModPerLevel
      t.float :rFlatHPModPerLevel
      t.float :FlatMPRegenMod
      t.float :rFlatMPModPerLevel
      t.float :rFlatMPRegenModPerLevel
      t.float :rFlatGoldPer10Mod
      t.float :rPercentTimeDeadMod
      t.float :rFlatMagicDamageModPerLevel
      t.float :FlatMPPoolMod
      t.float :FlatCritChanceMod
      t.float :rFlatPhysicalDamageModPerLevel
      t.float :PercentAttackSpeedMod
      t.float :FlatPhysicalDamageMod
      t.float :PercentLifeStealMod
      t.float :PercentSpellVampMod
      t.float :PercentHPPoolMod
      
    end
  end
end
