require_relative 'crawl'

@warrior = Crawl.new('John','Human','Fighter')
@warrior.run_program do |data|
  @last_message = '' unless @last_message
  @warrior.take_screen_shot unless @last_message == data[:message]
  p data[:message] if data[:message] != @last_message
  @last_message = data[:message]

  if data[:message].scan('Which weapon?') != []
    @warrior.press_buttons('a')
  elsif data[:stats][:title] != ''
    @warrior.display_screen
    @warrior.press_buttons(['S','Y'])
    @warrior.stop_program
  end
end

