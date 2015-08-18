# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150818133259) do

  create_table "champions", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.float  "armor"
    t.float  "armor_per_level"
    t.float  "ad"
    t.float  "ad_per_level"
    t.float  "range"
    t.float  "as_offset"
    t.float  "as_per_level"
    t.float  "hp"
    t.float  "hp_per_lvl"
    t.float  "hp5"
    t.float  "hp5_per_level"
    t.float  "mana_per_level"
    t.float  "mana"
    t.float  "mana5"
    t.float  "mana5_per_level"
    t.float  "msflat"
    t.float  "magres"
    t.float  "magres_per_level"
  end

  create_table "items", force: :cascade do |t|
    t.text    "description"
    t.string  "name"
    t.float   "ad"
    t.float   "ap"
    t.integer "total_cost"
    t.integer "base_cost"
    t.float   "as"
    t.float   "lifesteal"
    t.float   "arpen"
    t.float   "mrpen"
    t.float   "cdr"
    t.float   "mana"
    t.float   "hp"
    t.float   "mana5"
    t.float   "hp5"
    t.integer "msflat"
    t.float   "mspercent"
    t.float   "armor"
    t.float   "magres"
    t.float   "tenacity"
    t.float   "crit"
    t.float   "spellvamp"
  end

  create_table "runes", force: :cascade do |t|
    t.float  "FlatMagicDamageMod"
    t.float  "rPercentCooldownModPerLevel"
    t.float  "rPercentCooldownMod"
    t.float  "rFlatEnergyRegenModPerLevel"
    t.float  "rFlatHPRegenModPerLevel"
    t.float  "PercentMovementSpeedMod"
    t.float  "FlatEnergyPoolMod"
    t.float  "FlatHPPoolMod"
    t.float  "FlatEnergyRegenMod"
    t.float  "rFlatEnergyModPerLevel"
    t.float  "rFlatMagicPenetrationMod"
    t.float  "rFlatArmorPenetrationMod"
    t.float  "PercentEXPBonus"
    t.float  "FlatCritDamageMod"
    t.float  "FlatHPRegenMod"
    t.float  "FlatSpellBlockMod"
    t.float  "rFlatSpellBlockModPerLevel"
    t.float  "FlatArmorMod"
    t.float  "rFlatArmorModPerLevel"
    t.float  "rFlatHPModPerLevel"
    t.float  "FlatMPRegenMod"
    t.float  "rFlatMPModPerLevel"
    t.float  "rFlatMPRegenModPerLevel"
    t.float  "rFlatGoldPer10Mod"
    t.float  "rPercentTimeDeadMod"
    t.float  "rFlatMagicDamageModPerLevel"
    t.float  "FlatMPPoolMod"
    t.float  "FlatCritChanceMod"
    t.float  "rFlatPhysicalDamageModPerLevel"
    t.float  "PercentAttackSpeedMod"
    t.float  "FlatPhysicalDamageMod"
    t.float  "PercentLifeStealMod"
    t.float  "PercentSpellVampMod"
    t.float  "PercentHPPoolMod"
    t.string "name"
  end

end
