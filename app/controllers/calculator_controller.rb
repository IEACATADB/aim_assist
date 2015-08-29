class CalculatorController < ApplicationController
    require 'json'
    #TODO general  |comparison,error handling, masteries,abilities
    #TODO items    |cdr,crit dmg,%hp,tenacity,look for mising stats,index of specials,case by case for specials
    #TODO estimates|dmg reduction,per hit damage, per_hit/dps against target, fullcombo damage, fullcombo with auto weaving, per_spell 
    def index  
        #@api_key = Rails.application.secrets.API_KEY
       reset_session
       @runes =  Rune.all
        
    end 
   def search key
    @items = Item.all if key=="items"
   end
   def generate_json
       hash =Hash.new
       items= Hash.new
       arr = []
       session[:stuff][:items].each do |i|
        item=Hash.new
        item["id"] = i.to_s 
        item["count"] = 1
        arr<< item
       end
       items["items"] = arr 
       items["type"] = "core"
       hash["map"] = "any"
       hash["title"] =" Aim Assist"
       hash["priority"] = false 
       hash["mode"] = "any"
       hash["type"] = "custom"
       hash["sortrank"] = 0
       hash["champion"] =  session[:stuff][:champ]["key"]
       hash["blocks"] = items
       data = JSON.pretty_generate(hash)
       send_data data
       
   end
    
    private 
    def get_stuff
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
       
       
       @stuff = Hash.new
        @stuff[:runes] = @runes
        @stuff[:items] = @items
        @stuff[:champ] = @champ
       
      session[:stuff]= @stuff
       
       
    end

    def name_to_s_id string
        
        name = string.strip.downcase.gsub(/[ ]/,'')
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
    #def masteries_stats #maybe someday
   # end 
    def item_stats
        items = []
        hash = Hash.new(0)
        @items.each do |i|
            break if i === 0
            items << Item.find(i)
        end 
        items.each do |i|
        i.attributes.each do |key,value|
            hash[key]+=value.to_f if key != "id" && key != "description" && key!="name" && key!="base_cost"
            hash["cdr"]+=(value [/(\d+).{1,3}Cooldown Reduction/,0]).to_i if key =="description"
        end 
        end
       
       hash
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
   
     def runes_stats # I kind of fucked up with a way i'm doing this but whatever
        def r_per_lvl key
            key.gsub("Pool","")
        key = key+"PerLevel"
        key="r"+ key unless key[0]=='r'
        @summed_runes[key]*(@level)
        end 
        summed_runes=Hash.new(0)
        @runes.each do |i|
            rune =  Rune.find(i)
            rune.attributes.each do |k,v|
                summed_runes[k] += v unless v.is_a?(String) || v.blank?  
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
    def calc_estimates *stuff  #will have to rewrite lots of stuff to get special items in
     e_armor = 100
     e_armor = params[:e_armor].to_f unless params[:e_armor].blank?
     e_mr = 100
     e_mr = params[:e_magres].to_f unless params[:e_magres].blank? 
     @estimates["i_raw_dps"] = session[:initial][:estimates]["i_raw_dps"] unless session[:initial].nil?
     if params[:commit]=="search" 
        @estimates["i_avg"] = (@nice_stats["ad"]*(1+((@nice_stats["critChance"]*0.01)*(1+@nice_stats["critDamage"])))).to_f
        @estimates["i_raw_dps"] = (@estimates["i_avg"]*@nice_stats["as"]).to_f
     end
     @estimates["i_dps_against_target"] = @estimates["i_raw_dps"]*(100.0/(100.0+e_armor))
     @estimates["avg"] = @nice_stats["ad"]*(1+((@nice_stats["critChance"]*0.01)*(1+@nice_stats["critDamage"])))
     @estimates["raw_dps"] = @estimates["avg"]*@nice_stats["as"]
     @estimates["dps_against_target"] = @estimates["raw_dps"]*(100.0/(100.0+e_armor))
     @estimates["p_damage_reduction"]=100*(1-(100.0/(100.0+@nice_stats["armor"])))
     @estimates["s_damage_reduction"]=100*(1-(100.0/(100.0+@nice_stats["mr"])))
     
      
    end
    def split_runes
        runes = []
        @runes.each do |r|
        runes << Rune.find(r) 
        end
        hash = Hash.new
        hash[:reds] = runes.select{|i| i.attributes["r_type"] =="red"  }
        hash[:yellows] = runes.select{|i| i.attributes["r_type"] =="yellow"  }
        hash[:blues] =  runes.select{|i| i.attributes["r_type"] =="blue"  }
        hash[:blacks] =  runes.select{|i| i.attributes["r_type"] =="black" }
       @amounts = Hash.new()
       @amounts[:reds]= hash[:reds].count
       
       @amounts[:blues]= hash[:blues].count
       @amounts[:yellows]= hash[:yellows].count
       @amounts[:blacks]= hash[:blacks].count
       puts @amounts
        hash
        
    end
        
    def humanize_stats #combines stats and makes nicer/shorter keys 
        @nice_stats["ad"]=@item_stats["FlatPhysicalDamageMod"]+@runes_stats["FlatPhysicalDamageMod"]+@champ_stats["attackdamage"] #Attack Damage
        @nice_stats["as"]=(@champ_stats["attackspeed"]*(100+((@runes_stats["PercentAttackSpeedMod"]*100)+(@item_stats["PercentAttackSpeedMod"]*100)+(@champ_stats["attackspeedperlevel"]*(@level-1)))))/100.0 #Attack Speed
        @nice_stats["ap"]=@item_stats["FlatMagicDamageMod"]+@runes_stats["FlatMagicDamageMod"]
        @nice_stats["hp"]=(@champ_stats["hp"]+@item_stats["FlatHPPoolMod"]+@runes_stats["FlatHPPoolMod"])*(1+@runes_stats["PercentHPPoolMod"])
        @nice_stats["mp"]=@champ_stats["mp"]+@item_stats["FlatMPPoolMod"]+@runes_stats["FlatMPPoolMod"]
        @nice_stats["critChance"]=(@item_stats["FlatCritChanceMod"]+@runes_stats["FlatCritChanceMod"])*100
        @nice_stats["critDamage"]=2+@item_stats["FlatCritDamageMod"]+@runes_stats["FlatCritDamageMod"]
        @nice_stats["armor"]=@champ_stats["armor"]+@runes_stats["FlatArmorMod"]+@item_stats["FlatArmorMod"]
        @nice_stats["mr"]=@champ_stats["spellblock"]+@runes_stats['FlatSpellBlockMod']+@item_stats["FlatSpellBlockMod"]
        @nice_stats["cdr"]=@runes_stats["PercentCooldownMod"]+@item_stats["cdr"]
        @nice_stats["lifesteal"]=(@item_stats["PercentLifeStealMod"]*100)+@runes_stats["PercentLifeStealMod"]*100
        #here go specials
        @items.each do |i|
            case i
                when 1315..1319,3047,1338
                @nice_stats["aa_damage_reduction"]=0.1
                when 3031
                @nice_stats["critDamage"]+=0.5
                when 3089
                @nice_stats["ap"]*=1.35
            end
        end 
        
        case @champ["key"]
            when "Yasuo"
            @nice_stats["critChance"]*=2
            @nice_stats["critDamage"]*=0.9
        end 
        # here go limits
        @nice_stats["cdr"]=40 if @nice_stats["cdr"]>40
        @nice_stats["critChance"]=100 if @nice_stats["critChance"]>100
    end 
  
    def calc
        @stuff= Hash.new
        @estimates = Hash.new(0)
        @stuff = session[:stuff] 
        @level = 18
        @level = params[:level].to_i unless params[:level].nil?
        @items = @stuff[:items]
        @runes = @stuff[:runes]
        @champ =  @stuff[:champ]
        @item_stats = item_stats
        @runes_stats = runes_stats
        @champ_stats = champ_stats 
        @nice_stats = Hash.new(0)
        
        humanize_stats
        calc_estimates

        @stuff[:estimates]= @estimates
        @stuff[:stats]= @nice_stats
        @stuff[:champ]=@champ
        @stuff[:items]=@items
        @stuff[:runes]=@runes
        @stuff[:separated_runes]= split_runes
        @stuff[:amount]=@amounts
        session[:stuff]= @stuff
        session[:initial]=@stuff.to_a.to_h if params[:commit]=="search"
    end
    
   def change_champ 
   session[:stuff][:champ] = Champion.find(params[:champion])
   end
   
   def change_item
   session[:stuff][:items][params[:index].to_i] = params[:item].to_i
   end
   def change_rune
       amount = session[:stuff][:amount]
       reds_range = (1..amount[:reds]).to_a
       blues_range = ((reds_range.last+1)..(reds_range.last+amount[:yellows])).to_a
       yellows_range = ((blues_range.last+1)..(blues_range.last+amount[:blues])).to_a
       blacks_range = ((yellows_range.last+1)..(yellows_range.last+amount[:blacks])).to_a
       string = params[:id].to_s
       index = reds_range[(string[-1].to_i)] if string.include?("red")
       index = yellows_range[(string[-1].to_i)] if string.include?("yellow")
       index = blues_range[(string[-1].to_i)] if string.include?("blue")
       index = blacks_range[(string[-1].to_i)] if string.include?("black")
       
       session[:stuff][:runes][index-1] = params[:rune].to_i

   end
   def compare 
       hash = Hash.new
    
       hash["ad"] = session[:initial][:stats]["ad"] <=> session[:stuff][:stats]["ad"]
       hash["ap"] = session[:initial][:stats]["ap"] <=> session[:stuff][:stats]["ap"]
       hash["as"] = session[:initial][:stats]["as"] <=> session[:stuff][:stats]["as"]
       hash["critChance"] = session[:initial][:stats]["critChance"] <=> session[:stuff][:stats]["critChance"]
       hash["critDamage"] = session[:initial][:stats]["critDamage"] <=> session[:stuff][:stats]["critDamage"]
       hash["lifesteal"] = session[:initial][:stats]["lifesteal"] <=> session[:stuff][:stats]["lifesteal"]
       hash["hp"] = session[:initial][:stats]["hp"] <=> session[:stuff][:stats]["hp"]
       hash["mp"] = session[:initial][:stats]["mp"] <=> session[:stuff][:stats]["mp"]
       hash["armor"] = session[:initial][:stats]["armor"] <=> session[:stuff][:stats]["armor"]
       hash["mr"] = session[:initial][:stats]["mr"] <=>  session[:stuff][:stats]["mr"]
       hash["cdr"] = session[:initial][:stats]["cdr"] <=> session[:stuff][:stats]["cdr"]
       session[:compared] = hash
       est = Hash.new
       p session[:initial][:estimates]
       p session[:stuff][:estimates]
       est["per_hit"] = session[:initial][:estimates]["i_avg"] <=> session[:stuff][:estimates]["avg"]
       est["raw_dps"] = session[:initial][:estimates]["i_raw_dps"] <=> session[:stuff][:estimates]["raw_dps"]
       est["target_dps"] = session[:stuff][:estimates]["i_dps_against_target"] <=> session[:stuff][:estimates]["dps_against_target"]
       session[:compared][:estimates] = est
   end
   
  
   helper_method :calc
   helper_method :get_stuff
   helper_method :search
   helper_method :change_champ
   helper_method :change_item
   helper_method :change_rune
   helper_method :compare
   helper_method :generate_json
    
    
end
