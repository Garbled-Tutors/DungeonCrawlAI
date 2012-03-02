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

  def play_turn(warrior, info)

    @turn_count = 0 unless @turn_count
    enemies = info[:visible][:creatures].length
    if @turn_count == 0
      warrior.update_visible
      @turn_count = 1
      return
    end
    p info
    exit

    exit if enemies > 2
    if enemies == 2
      warrior.update_visible
    elsif info[:visible][:creatures] == []
      warrior.autoexplore
    elsif info[:stats][:magic][0].to_i > 0
      warrior.cast
    else
      warrior.wait
    end
  end

end

