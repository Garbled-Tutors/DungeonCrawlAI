class Imhotep<Player
  NAME = 'Imhotep'
  SPECIES = 'Mummy'
  BACKGROUND = 'Summoner'
  WEAPON = 'short sword'
  PLAYER_DETAILS = {:name => NAME, :species => SPECIES,
    :background => BACKGROUND, :weapon => WEAPON}

  def get_details
    PLAYER_DETAILS
  end


  # Example info value
  #{:stats=>{:name, :species, :background, :health=>["13", "13"], :magic=>["2", "3"], :ac, :str, :ev, :int, :sh, :dex, :branch, :floor, :exp, :weapon, :quivered}
  #:visible=>{:hero, :creatures, :items, :stairs, :walls, :ground, :map},
  #:map=>{},
  #:creatures=>[{:name=>"bat", :coordinates=>[16, 9], :notes=>["friendly", "summoned"]}, {:name=>"hobgoblin", :coordinates=>[18, 15], :notes=>["resting", "wielding a club"]}]}

  def play_turn(warrior, info)
    if info[:visible][:creatures].length > 0
      #creatures exist check to see if they are friendly
      if info[:creatures] == nil
        warrior.update_visible
        return
      else
        enemies_seen = info[:creatures].map { |creature| creature[:notes].include?('summoned')}.include?(true)

        if enemies_seen and info[:stats][:magic][0].to_i > 0
          warrior.cast('Summon Small Mammals')
          return
        elsif enemies_seen
          warrior.wait
          return
        end
      end
      warrior.autoexplore
    end
  end
end

