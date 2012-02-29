require_relative 'player'
require_relative 'common'
require_relative 'screen_parser'
require_relative 'terminal_emulator'

class Crawl
  def initialize
    @key_strokes = []
    @functions_waiting_to_run = []
    @player = Player.new
    @saved_info = {:map => {} }
    run_program
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

  private
  def parse_map(output)
    @saved_info = ScreenParser.parse_full_map(output)
    27.chr
  end

  def run_program
    cmd_arguements = Commmon.create_crawl_arguments(@player.get_details)
    @terminal = TerminalEmulator.new
    @terminal.execute_program('crawl' + cmd_arguements,0.2) do |pipe, output|
      Commmon.display_screen(output)

      #player's move
      if @functions_waiting_to_run == []
        info = ScreenParser.parse_screen(output)
        @saved_info.each { |key,value| info[key] = value }

        @key_strokes = ['.'] # do nothing
        @player.play_turn(self, info)
        @terminal.input_data(pipe, @key_strokes)
      else
        func_name = @functions_waiting_to_run.shift
        @key_strokes = send(func_name, output)
      end
    end
  end
end

Crawl.new
