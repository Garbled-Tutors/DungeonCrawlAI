require_relative 'crawl'

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

  def make_move(info)
    if info[:visible][:creatures] == []
      :auto_explore
    elsif info[:stats][:magic][0].to_i > 0
      :cast
    end
  end
end

player = Player.new
crawl = Crawl.new(player.get_details)
crawl.run_program do |info|
  player.make_move(info)
end

