class Player
  NAME = 'Joe'
  SPECIES = 'Mummy'
  BACKGROUND = 'Summoner'
  WEAPON = 'short sword'
  PLAYER_DETAILS = {:name => NAME, :species => SPECIES,
    :background => BACKGROUND, :weapon => WEAPON}

  def get_details
    PLAYER_DETAILS
  end

  def play_turn(warrior, info)
    p info
    warrior.autoexplore
    warrior.update_map if info[:map] == {}
  end

end
