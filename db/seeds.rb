# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

@api_key = Rails.application.secrets.API_KEY


def get_items 
    list = JSON.parse((HTTParty.get ('https://global.api.pvp.net/api/lol/static-data/euw/v1.2/item?itemListData=sanitizedDescription,stats,gold&api_key='+@api_key)).body)
    list = list["data"]
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

(get_items).each_value do |item|
    
    item_= Item.create(id: item["id"],name: item["name"],description: item["sanitizedDescription"],cost: item["gold"]["total"])
    item["stats"].each do |key,value|
    item_.update(key.to_sym => value) 
    end 

end
(get_champ_list).each_value do |champ|
    stats = champ["stats"]
    
 champion =  Champion.create(id: champ["id"], key: champ["key"], name: champ["name"] )
 stats.each do |key,value|
 champion.update(key.to_sym => value)
 end 
end 
get_runes.each do |id,hash|
 rune = Rune.create(id: id, name: hash["name"] ,r_type: hash["rune"]["type"].to_s,description: hash["description"])
 hash["stats"].each do |key,value|
 rune.update(key.to_sym => value)
 end 
end 