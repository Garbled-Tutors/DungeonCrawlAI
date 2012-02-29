require_relative 'crawl_interface'

class Crawl
  PLAYER_MAIN_DETAILS = {:name => 'Player', :species => 'Human',
    :background => 'Fighter'}
  PLAYER_SECOND_DETAILS = {:weapon => 'short sword'}
  ACTION_LIST = [:walk, :auto_explore, :cast]

  def initialize(details)
    @cmd_arguements = ''
    PLAYER_MAIN_DETAILS.each do |key,value|
      new_value = (details[key] || value)
      @cmd_arguements += " -#{key} #{new_value}"
    end

    @cmd_arguements += ' -extra-opt-first'
    PLAYER_SECOND_DETAILS.each do |key,value|
      new_value = (details[key] || value)
      @cmd_arguements += " #{key}='#{new_value}'"
    end
  end

  def run_program(&block)
    @interface = CrawlInterface.new
    @interface.run_program(@cmd_arguements) do |pipe, output|
      @interface.display_screen(output)
      info = @interface.parse_screen(output)
      command = block.call(info)
      if command == :auto_explore
        pipe.putc 'o'
      elsif command == :cast
        pipe.putc 'z'
        sleep(0.1)
        pipe.putc 'a'
      end
    end
  end

end

