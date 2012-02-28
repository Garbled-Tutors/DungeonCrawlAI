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

  def make_move(crawl,pipe,output)
    crawl.display_screen(output)
    info = crawl.parse_screen(output)
    if info[:visible][:creatures] == []
      pipe.putc 'o'
    elsif info[:stats][:magic][0].to_i > 0
      pipe.putc 'z'
      sleep(0.1)
      pipe.putc 'a'
    else
      crawl.manual_control(pipe)
    end
  end
end

player = Player.new
crawl = Crawl.new(player.get_details)
crawl.run_program do |pipe,output|
  player.make_move(crawl,pipe,output)
end

