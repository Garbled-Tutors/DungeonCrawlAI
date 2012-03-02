require_relative 'player'
require_relative 'common'
require_relative 'screen_parser'
require_relative 'terminal_emulator'

class Crawl
  def initialize
    @key_strokes = []
    @functions_waiting_to_run = []
    @player = Imhotep.new #@player = Player.new
    reset_saved_info
    run_program
  end

  def reset_saved_info
    @saved_info = {:map => {}, :creatures => nil }
  end

  def walk(direction = :north)
  end

  def shoot(coordinates, ammunition = nil)
  end

  def swing(direction = :north)
  end

  def autoexplore
    @key_strokes = 'o'
  end

  def cast(spell = :default, coordinates = nil)
    @key_strokes = 'za'
  end

  def drink(potion)
  end

  def eat(item)
  end

  def wait
    @key_strokes = '.'
  end

  def update_map
    @key_strokes = 'X'
    @functions_waiting_to_run = ['parse_map']
  end

  def update_visible
    @key_strokes = 'x+'
    @functions_waiting_to_run = ['parse_visible']
  end

  def is_direction_vacant?(info, direction)
    hero_location = info[:visible][:hero]
    square = Commmon.get_new_coordinates(hero_location, direction)
    wall_exists = info[:visible][:walls].includes?(square)
    creature_exists = info[:visible][:creatures].includes?(square)
    !wall_exists and !creature_exists
  end

  private
  def parse_map(output)
    @saved_info = ScreenParser.parse_full_map(output)
    27.chr
  end


  def parse_visible(output)
    if ScreenParser.get_object_notes(output) == nil
      creature_details = {:creatures => ScreenParser.parse_creatures(output)}
      @saved_info.merge!(creature_details)
      return 27.chr
    end
    @functions_waiting_to_run = ['parse_visible']
    return '+'
  end

  def run_program
    run_count = 0
    cmd_arguements = Commmon.create_crawl_arguments(@player.get_details)
    @terminal = TerminalEmulator.new
    @terminal.execute_program('crawl' + cmd_arguements,0.2) do |pipe, output|
      if @functions_waiting_to_run == []
        Commmon.display_screen(output)
        sleep(1)
        info = ScreenParser.parse_screen(output)
        @saved_info.each { |key,value| info[key] = value }

        @key_strokes = ['.'] # do nothing
        @player.play_turn(self, info)
        @terminal.input_data(pipe, @key_strokes)
        reset_saved_info
      else
        func_name = @functions_waiting_to_run.shift
        @key_strokes = send(func_name, output)
        @terminal.input_data(pipe, @key_strokes)
      end
    end
  end
end

Crawl.new
