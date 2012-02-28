require_relative 'crawl'

NAME = 'Joe'
SPECIES = 'Mummy'
BACKGROUND = 'Summoner'
WEAPON = 'short sword'
PLAYER_DETAILS = {:name => NAME, :species => SPECIES,
  :background => BACKGROUND, :weapon => WEAPON}

# read a character without pressing enter and without printing to the screen
def read_char
  begin
    # save previous state of stty
    old_state = `stty -g`
    # disable echoing and enable raw (not having to press enter)
    system "stty raw -echo"
    c = STDIN.getc.chr
    # gather next two characters of special keys
    if(c=="\e")
      extra_thread = Thread.new{
        c = c + STDIN.getc.chr
        c = c + STDIN.getc.chr
      }
      # wait just long enough for special keys to get swallowed
      extra_thread.join(0.00001)
      # kill thread so not-so-long special keys don't wait on getc
      extra_thread.kill
    end
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
    puts ex.backtrace
  ensure
    # restore previous state of stty
    system "stty #{old_state}"
  end
  return c
end

@warrior = Crawl.new(PLAYER_DETAILS)
@warrior.run_program do |data|
  @last_message = '' unless @last_message
  @warrior.take_screen_shot unless @last_message == data[:message]
  p data[:message] if data[:message] != @last_message
  @last_message = data[:message]

  `reset`
  @warrior.take_screen_shot
  sleep(0.5)
  @warrior.display_screen
  response = read_char
  p response
  @warrior.press_buttons([response])
  #if data[:stats] != nil and data[:stats][:magic_remaining] != nil
    #@warrior.press_buttons(['S','y'])
    #@warrior.stop_program
  #end
  #if data[:stats] != nil
    #if data[:stats][:magic_remaining] > 0 and data[:objects][:creatures].length > 0
      #p 'Summoning'
      #@warrior.press_buttons(['z',97])
    #else
      #p 'Searching'
      #@warrior.press_buttons(['o'])
    #end
  #end
end

