require_relative 'crawl'

@warrior = Crawl.new
@warrior.run_program do |data|
  @last_message = '' unless @last_message
  @warrior.take_screen_shot unless @last_message == data[:message]
  p data[:message] if data[:message] != @last_message
  #p data[:stats] if data[:message] != @last_message
  @last_message = data[:message]

  if data[:message] == 'What is your name today? '
    @warrior.press_buttons(['John', 13])
  elsif data[:message].scan('Which one?') != []
    @warrior.press_buttons('a')
  elsif data[:message].scan('What kind of character are you?') != []
    @warrior.press_buttons('a')
  elsif data[:message].scan('Which weapon?') != []
    @warrior.press_buttons('a')
  elsif data[:stats][:title] != ''
    @warrior.display_screen
    @warrior.press_buttons(['S','Y'])
    @warrior.stop_program
  end
end

