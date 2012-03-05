class DebugInfo<Player
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
    @turn_count = 0 unless @turn_count
    p "Starting Debug"
    p "Hero: #{info[:visible][:hero]}"
    p "Visible creatures: #{info[:visible][:creatures]}"
    warrior.update_visible if @turn_count == 0
    p "Creture info #{info[:creatures]}" if @turn_count == 1
    exit if @turn_count > 0
    @turn_count += 1
  end
end

