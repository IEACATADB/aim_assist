class CalculatorController < ApplicationController
    #respond_to :html, :js
    
    def index 
        @api_key = Rails.application.secrets.API_KEY
        @region = params[:region].downcase
        @stats = Hash.new(0)
        @items = []
        id = name_to_s_id params[:name]
        if params[:m_id].blank?
            @items = last_game_data id 
        else 
            @items = match_data id,params[:m_id]
        end 
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
        arr = []
        response = JSON.parse HTTParty.get( 'https://'+@region+'.api.pvp.net/api/lol/'+@region+'/v2.2/matchhistory/'+s_id+'?beginIndex=0&endIndex=1&api_key='+@api_key).body
        @champ = Champion.find(response["matches"][0]["participants"][0]["championId"])
        6.times do |i|
            break if response["matches"][0]["participants"][0]["stats"]["item"+i.to_s] == nil
            arr << response["matches"][0]["participants"][0]["stats"]["item"+i.to_s]
        end
        arr
    end 
    
    
    def match_data s_id,match_id 
        arr = []
        participant = 0
    
        response = JSON.parse HTTParty.get('https://'+@region+'.api.pvp.net/api/lol/'+@region+'/v2.2/match/'+match_id+'?includeTimeline=false&api_key='+@api_key).body
    
        response["participantIdentities"].each do 
            break if response["participantIdentities"][participant]["player"]["summonerId"] == s_id
            participant +=1 
        end 
        @champ = Champion.find(response["participants"][participant]["championId"])
        6.times do |i|
         break if response["participants"][participant]["stats"]["item"+i.to_s] == nil
            arr << response["participants"][participant]["stats"]["item"+i.to_s]
        end
     
        arr
    end 
    def sum_item_stats
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
       hash#.delete_if{|k,v| v.blank?||v==0.0}
    end 
    
    def champ_stats
        
        @stats["crit"]*=100
        @stats["ad"] += @champ["ad"]+(@champ["ad_per_level"]*(@level-1))
        @stats["as"] = ( (0.625 / ( 1+@champ["as_offset"] ) )*( 100+( (@champ["as_per_level"]*@level-1) + @stats["as"] *100 ) ) ) / 100.0
         if @champ["key"] == "Yasuo"
         @stats["crit"] *=2
         end
         @stats["armor"] +=@champ["armor"]+(@champ["armor_per_level"]*(@level-1))
         @stats["magres"] +=@champ["magres"]+(@champ['magres_per_level']*(@level-1))
         @stats["movespeed"] = (@champ["msflat"]+@stats["msflat"])*(1+@stats["mspercent"]) #placeholder
         @stats["cdr"] = 40 if @stats["cdr"]>40
         
    end 
    def calc_estimates *stuff  #will have to rewrite lots of stuff to get special items in
     
     @estimates["raw_dps"] = (@stats["ad"]*(1+@stats["crit"]))*@stats["as"]
     
    end
     def add_runes_stats
     @stats["ad"] += @runes_stats["FlatPhysicalDamageMod"]+((@level-1)*@runes_stats["rFlatPhysicalDamageModPerLevel"])
     @stats["ap"] += @runes_stats["FlatMagicDamageMod"]+((@level-1)*@runes_stats["rFlatMagicDamageModPerLevel"])
     @stats["crit"]+= @runes_stats["FlatCritChanceMod"]
     @stats["crit_damage"]+=@runes_stats["FlatCritDamageMod"]
     @stats["armor_pen"]+=@runes_stats["rFlatArmorPenetrationMod"]
     @stats["magic_pen"]+=@runes_stats["rFlatMagicPenetrationMod"]
     end
    
    def calc
        @estimates = Hash.new(0)
        @level = 18
        @level = params[:level].to_i unless params[:level].to_i==0
        @items = session[:items]
        @champ = session[:champ]
        @stats = sum_item_stats
        add_runes_stats
        champ_stats 
        
        calc_estimates
        session[:estimates] = @estimates
        session[:stats] = @stats
    end
   
   helper_method :calc
    
end
