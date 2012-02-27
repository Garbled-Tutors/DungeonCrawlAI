require_relative 'crawl'

NAME = 'Joe'
SPECIES = 'Mummy'
BACKGROUND = 'Summoner'
WEAPON = 'short sword'
PLAYER_DETAILS = {:name => NAME, :species => SPECIES,
  :background => BACKGROUND, :weapon => WEAPON}

@warrior = Crawl.new(PLAYER_DETAILS)
@warrior.run_program do |data|
  @last_message = '' unless @last_message
  @warrior.take_screen_shot unless @last_message == data[:message]
  p data[:message] if data[:message] != @last_message
  @last_message = data[:message]

  @warrior.display_screen
  if data[:stats] != nil and data[:stats][:magic_remaining] != nil
    @warrior.press_buttons(['S','y'])
    @warrior.stop_program
  end
  if data[:stats] != nil
    if data[:stats][:magic_remaining] > 0 and data[:objects][:creatures].length > 0
      @warrior.press_buttons(['z','a'])
    else
      @warrior.press_buttons(['o'])
    end
  end
end

