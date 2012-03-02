class Player
  NAME = 'Player'
  SPECIES = 'Human'
  BACKGROUND = 'Fighter'
  WEAPON = 'short sword'
  PLAYER_DETAILS = {:name => NAME, :species => SPECIES,
    :background => BACKGROUND, :weapon => WEAPON}

  def get_details
    PLAYER_DETAILS
  end

  def play_turn(warrior, info)
  end

end

