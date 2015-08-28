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

ActiveRecord::Schema.define(version: 20150825192659) do

  create_table "champions", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.float  "armor"
    t.float  "armorperlevel"
    t.float  "attackdamage"
    t.float  "attackdamageperlevel"
    t.float  "attackrange"
    t.float  "attackspeedoffset"
    t.float  "attackspeedperlevel"
    t.float  "crit"
    t.float  "critperlevel"
    t.float  "hp"
    t.float  "hpperlevel"
    t.float  "hpregen"
    t.float  "hpregenperlevel"
    t.float  "movespeed"
    t.float  "mp"
    t.float  "mpperlevel"
    t.float  "mpregen"
    t.float  "mpregenperlevel"
    t.float  "spellblock"
    t.float  "spellblockperlevel"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.float  "cost"
    t.float  "FlatMPPoolMod"
    t.float  "FlatMagicDamageMod"
    t.float  "FlatCritChanceMod"
    t.float  "PercentAttackSpeedMod"
    t.float  "PercentMovementSpeedMod"
    t.float  "FlatArmorMod"
    t.float  "FlatMovementSpeedMod"
    t.float  "FlatHPPoolMod"
    t.float  "FlatPhysicalDamageMod"
    t.float  "PercentLifeStealMod"
    t.float  "FlatSpellBlockMod"
    t.float  "FlatHPRegenMod"
    t.float  "FlatMPRegenMod"
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
    t.string "r_type"
    t.string "description"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

end
