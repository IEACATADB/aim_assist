class CalculatorController < ApplicationController
    #respond_to :html, :js
    
    def index 
        @api_key = Rails.application.secrets.API_KEY
        @region = params[:region].downcase
        
        @items = []
        @runes = []
        id = name_to_s_id params[:name]
        if params[:m_id].blank?
             last_game_data id 
        else 
             match_data id,params[:m_id]
        end 
        session[:runes] = @runes
        session[:items] = @items
        session[:champ] = @champ
    end 
   
    
    private 
    def name_to_s_id string
        
        name = string.strip.downcase.gsub(/' '/,'')
        response = JSON.parse HTTParty.get( 'https://'+@region+'.api.pvp.net/api/lol/'+@region+'/v1.4/summoner/by-name/'+name+'?api_key='+@api_key).body
        
        id = response[name]["id"].to_s
        
    end
    
    
    def last_game_data s_id
        
        response = JSON.parse HTTParty.get( 'https://'+@region+'.api.pvp.net/api/lol/'+@region+'/v2.2/matchhistory/'+s_id+'?beginIndex=0&endIndex=1&api_key='+@api_key).body
        @champ = Champion.find(response["matches"][0]["participants"][0]["championId"])
        6.times do |i|
            break if response["matches"][0]["participants"][0]["stats"]["item"+i.to_s] == nil
            @items << response["matches"][0]["participants"][0]["stats"]["item"+i.to_s]
        end
        response["matches"][0]["participants"][0]["runes"].each do |rune|
            rune["rank"].times do |n|
                @runes<< rune["runeId"]
            end
        end
    end 
    
    
    def match_data s_id,match_id 
        
        
        participant = 0
    
        response = JSON.parse HTTParty.get('https://'+@region+'.api.pvp.net/api/lol/'+@region+'/v2.2/match/'+match_id+'?includeTimeline=false&api_key='+@api_key).body
    
        response["participantIdentities"].each do 
            break if response["participantIdentities"][participant]["player"]["summonerId"] == s_id
            participant +=1 
        end 
        @champ = Champion.find(response["participants"][participant]["championId"])
        6.times do |i|
         break if response["participants"][participant]["stats"]["item"+i.to_s] == nil
            @items << response["participants"][participant]["stats"]["item"+i.to_s]
        end
        response["participants"][participant]["runes"].each do |i|
            i["rank"].times do |n|
                @runes<< i["runeId"]
            end
        end
        
    end 
    def item_stats
        items = []
        hash = Hash.new(0)
        @items.each do |i|
            items << Item.find(i)
        end 
        items.each do |i|
        i.attributes.each do |key,value|
            hash[key]+=value.to_f if key != "id" && key != "description" && key!="name" && key!="base_cost"
        end 
        end
        hash["FlatCritChanceMod"]*=100
       hash#.delete_if{|k,v| v.blank?||v==0.0}
    end 
    
    def champ_stats
        def c_per_lvl key
        key+="perlevel"
        @champ[key]*(@level-1)
        end 
        hash = Hash.new(0)
        hash["key"] =@champ["key"]
        hash["attackdamage"] = @champ["attackdamage"]+ c_per_lvl("attackdamage")
        hash["attackspeed"] =  (0.625 / ( 1+@champ["attackspeedoffset"] )) 
        hash["attackspeedperlevel"]=@champ["attackspeedperlevel"]
        hash["armor"] = @champ["armor"] + c_per_lvl("armor")
        hash["spellblock"] =@champ["spellblock"]+c_per_lvl("spellblock")
        hash["movespeed"] = @champ["movespeed"] #placeholder
        hash["hp"]=@champ["hp"]+c_per_lvl("hp")
        hash["hpregen"]=@champ["hpregen"]+c_per_lvl("hpregen")
        hash["mp"]=@champ["mp"]+c_per_lvl("mp")
        hash["mpregen"]=@champ["mpregen"]+c_per_lvl("mpregen")
        hash["range"]=@champ["range"] 
        hash
    end 
    def calc_estimates *stuff  #will have to rewrite lots of stuff to get special items in
     
     #@estimates["raw_dps"] = (@stats["FlatPhysicalDamageMod"]*(1+@stats["FlatCritChanceMod"]))*@stats["as"]
     
    end
     def runes_stats # i kind of fucked in a way i'm doing this but whatever
        def r_per_lvl key
            key.gsub("Pool","")
        key = key+"PerLevel"
        key="r"+ key unless key[0]=='r'
        @summed_runes[key]*(@level-1)
        end 
        summed_runes=Hash.new(0)
        @runes.each do |i|
            rune =  Rune.find(i)
            p rune
            rune.attributes.each do |k,v|
                summed_runes[k] += v unless k=="name" || v.blank?
            end
        end
        @summed_runes= summed_runes
       
     
     
     hash = Hash.new(0)
     hash["FlatPhysicalDamageMod"]= summed_runes["FlatPhysicalDamageMod"]+r_per_lvl("FlatPhysicalDamageMod")
     hash["FlatMagicDamageMod"]=summed_runes["FlatMagicDamageMod"]+r_per_lvl("FlatMagicDamageMod")
     hash["PercentAttackSpeedMod"]=summed_runes["PercentAttackSpeedMod"]
     hash["PercentCooldownMod"]=summed_runes["rPercentCooldownMod"]+r_per_lvl("rPercentCooldownMod")
     hash["PercentMovementSpeedMod"]=summed_runes["PercentMovementSpeedMod"]
     hash["FlatCritChanceMod"]=summed_runes["FlatCritChanceMod"]
     hash["FlatCritDamageMod"]=summed_runes["FlatCritDamageMod"]
     hash["FlatArmorMod"]=summed_runes["FlatArmorMod"]+r_per_lvl("FlatArmorMod")
     hash["FlatSpellBlockMod"]=summed_runes["FlatSpellBlockMod"]+r_per_lvl("FlatSpellBlockMod")
     hash["FlatHPPoolMod"]=summed_runes["FlatHPPoolMod"]+r_per_lvl("FlatHPPoolMod")
     hash["FlatHPRegenMod"]=summed_runes["FlatHPRegenMod"]+r_per_lvl("FlatHPRegenMod")
     hash["FlatMPPoolMod"]=summed_runes["FlatMPPoolMod"]+r_per_lvl("FlatMPPoolMod")
     hash["FlatMPRegenMod"]=summed_runes["FlatMPRegenMod"]+r_per_lvl("FlatMPRegenMod")
     hash["PercentHPPoolMod"]=summed_runes["PercentHPPoolMod"]
     hash["FlatEnergyPoolMod"]=summed_runes["FlatEnergyPoolMod"]+r_per_lvl("FlatEnergyPoolMod")
     hash["FlatEnergyRegenMod"]=summed_runes["FlatEnergyRegenMod"]
     hash["rFlatArmorPenetrationMod"]=summed_runes["rFlatArmorPenetrationMod"]
     hash["rFlatMagicPenetrationMod"]=summed_runes["rFlatMagicPenetrationMod"]
     hash["PercentEXPBonus"]=summed_runes["PercentEXPBonus"]
     hash["rFlatGoldPer10Mod"]=summed_runes["rFlatGoldPer10Mod"]
     hash["rPercentTimeDeadMod"]=summed_runes["rPercentTimeDeadMod"]
     hash["PercentLifeStealMod"]=summed_runes["PercentLifeStealMod"]
     hash["PercentSpellVampMod"]=summed_runes["PercentSpellVampMod"]
     hash
     end
    def humanize_stats #combines stats and makes nicer/shorter keys 
    @nice_stats["ad"]=@item_stats["FlatPhysicalDamageMod"]+@runes_stats["FlatPhysicalDamageMod"]+@champ_stats["attackdamage"] #Attack Damage
    @nice_stats["as"]=@champ_stats["attackspeed"]*(100+(@runes_stats["PercentAttackSpeedMod"]+@item_stats["PercentAttackSpeedMod"]+(@champ_stats["attackspeedperlevel"]*(@level-1)))) #Attack Speed
    @nice_stats["ap"]=@item_stats["FlatMagicDamageMod"]+@runes_stats["FlatMagicDamageMod"]
    @nice_stats["hp"]=(@item_stats["FlatHPPoolMod"]+@runes_stats["FlatHPPoolMod"])*(1+@runes_stats["PercentHPPoolMod"])
    @nice_stats["mp"]=@item_stats["FlatMPPoolMod"]+@runes_stats["FlatMPPoolMod"]
    end 
    def calc
        @estimates = Hash.new(0)
        @level = 18
        @level = params[:level].to_i unless params[:level].blank?
        @items = session[:items]
        @runes = session[:runes]
        @champ = session[:champ]
        @item_stats = item_stats
        @runes_stats = runes_stats
        @champ_stats = champ_stats 
        @nice_stats = Hash.new(0)
        
        humanize_stats
        calc_estimates
        session[:estimates] = @estimates
        session[:stats] = @nice_stats
    end
   
   helper_method :calc
    
end
