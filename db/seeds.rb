# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

@special_items = Hash.new #items that require extra calculations i.e percent increase, on hit effects or unique bonus 
@special_ignore=[3068,3067] #ids to exclude from list of uniques
@special_include=[3124,3152,3035,3135,3087,3031,3047] #ids to include  to list of uniques, has priority over other conditions 
@api_key = Rails.application.secrets.API_KEY
def parse_item (hash)
    stats = Hash.new {|hash,key|hash[key] = 0 }
    stats["id"] = hash["id"].to_s
    stats["name"] = hash["name"]
    stats["total_cost"] = hash["gold"]["total"]
    stats["base_cost"] = hash["gold"]["base"]
    stats["description"] = hash["sanitizedDescription"]
    hash["stats"].each do |key,value|
        stats[key] = value
    end 
    get_not_included_stats(hash["sanitizedDescription"]).each do |key,value|
        stats[key] = value
    end
    @special_items[hash["id"]] = hash["name"] if @special_include.include?(hash["id"])|| 
    (!(hash["name"].include?("Enchantment")) &&
    hash["sanitizedDescription"].include?("UNIQUE Passive") && 
    !(@special_ignore.include?(hash["id"])))
    stats
end 
def get_not_included_stats(string)
    stats = Hash.new
    stats["cdr"] = string[/(\d+).{1,2}Cooldown Reduction/i].to_f if string.include?("Cooldown")
    stats["armor_pen"] = string[/(\d+).{1,2}armor Penetration/i].to_f if string.include?("Armor Penetration")
    stats["magic_pen"] = string[/(\d+).{1,2}Magic Penetration/i].to_f if string.include?("Magic Penetration")
    stats["spellvamp"] = string[/(\d+).{1,3}Spell Vamp/i].to_f if string.include?("Vamp")
    stats["tenacity"] = string[/Reduces.+by.(\d+)/].to_f if string.include?("tenacity")
    stats 
end
def fetch_list 
    list = JSON.parse((HTTParty.get ('https://global.api.pvp.net/api/lol/static-data/euw/v1.2/item?itemListData=sanitizedDescription,stats,gold&api_key='+@api_key)).body)
    list = list["data"]
end
def parse_list(list)
    hash = Hash.new(0)
    list.each_value do |i|
        stats = parse_item i 
        hash[stats["id"]] = stats
    end
    hash
end 
def get_champ_list
    list = JSON.parse ((HTTParty.get ('https://global.api.pvp.net/api/lol/static-data/euw/v1.2/champion?dataById=true&champData=stats&api_key='+@api_key)).body)
    list = list["data"]
    list
end 
def get_runes
    list = JSON.parse ((HTTParty.get ('https://global.api.pvp.net/api/lol/static-data/euw/v1.2/rune?runeListData=stats&api_key='+@api_key)).body)
    list = list["data"]
    list
end 
(parse_list fetch_list).each_value do |item|
    
    Item.create(id: item["id"],name: item["name"],description: item["description"],
    ad: item["FlatPhysicalDamageMod"], ap: item["FlatMagicDamageMod"], 
    total_cost: item["total_cost"], base_cost: item["base_cost"],
    as: item["PercentAttackSpeedMod"], lifesteal: item["PercentLifeStealMod"],
    arpen: item["armor_pen"], mrpen: item["magic_pen"], cdr: item["cdr"],
    spellvamp: item["spellvamp"], mana: item["FlatMPPoolMod"],
    mana5: item["FlatMPRegenMod"], hp5: item["FlatHPRegenMod"],
    hp: item["FlatHPPoolMod"], armor: item["FlatArmorMod"],
    magres: item["FlatSpellBlockMod"], tenacity: item["tenacity"],
    crit: item["FlatCritChanceMod"],msflat: item["FlatMovementSpeedMod"],
    mspercent: item["PercentMovementSpeedMod"])
end
(get_champ_list).each_value do |champ|
    stats = champ["stats"]
    
 Champion.create(id: champ["id"], key: champ["key"], name: champ["name"], 
 armor: stats["armor"], armor_per_level: stats["armorperlevel"],
 ad: stats["attackdamage"], ad_per_level: stats["attackdamageperlevel"],
 range: stats["attackrange"], as_offset: stats["attackspeedoffset"],
 as_per_level: stats["attackspeedperlevel"], hp: stats["hp"],
 hp_per_lvl: stats["hpperlevel"], hp5: stats["hpregen"], 
 hp5_per_level: stats["hpregenperlevel"], mana: stats["mp"],
 mana_per_level: stats["mpperlevel"],mana5: stats["mpregen"],
 mana5_per_level: stats["mpregenperlevel"],magres: stats["spellblock"],
 magres_per_level: stats["spellblockperlevel"], msflat: stats["movespeed"])
end 
get_runes.each do |id,hash|
 rune = Rune.create(id: id,name: hash["name"])
 hash["stats"].each do |key,value|
 rune.update(key.to_sym => value)
 end 
end 