require_relative 'terminal_emulator'
require_relative 'output_parser'

class Crawl
  ITEM_TYPES = {')' => :weapon,'(' => :missle,'[' => :armor,'%' => :food,'?' => :scroll,
    '!' => :potion,'/' => :ward,'=' => :ring,'"' => :amulet,'\\' => :stave,'|' => :rod,
    '+' => :spellbook,':' => :spellbook,'}' => :misc,'$' => :gold}
  KNOWN_OBJECTS = {:ground => ['.'], :walls => ['#'], :creatures => ('a'..'z').to_a,
    :hero => ['@'], :items => ITEM_TYPES.keys}
  PLAYER_MAIN_DETAILS = {:name => 'Player', :species => 'Human',
    :background => 'Fighter'}
  PLAYER_SECOND_DETAILS = {:weapon => 'short sword'}

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
    @terminal = TerminalEmulator.new
    @terminal.execute_program('crawl' + @cmd_arguements,0.2) do |pipe, output|
      block.call(pipe,output)
    end
  end

  def take_screen_shot(output)
    @terminal.take_screen_shot(output)
  end

  def display_screen(output)
    OutputParser.new.display_screen(output)
  end

  def manual_control(pipe)
    @terminal.input_data(pipe, @terminal.read_char)
  end

  def parse_screen
  end

  def parse_player_stats(screen)
  end

  def parse_floor_map(floor_map)
  end
end

NAME = 'Joe'
SPECIES = 'Mummy'
BACKGROUND = 'Summoner'
WEAPON = 'short sword'
PLAYER_DETAILS = {:name => NAME, :species => SPECIES,
  :background => BACKGROUND, :weapon => WEAPON}

@crawl = Crawl.new(PLAYER_DETAILS)
@crawl.run_program do |pipe,output|
  @crawl.take_screen_shot(output)
  @crawl.display_screen(output)
  @crawl.manual_control(pipe)
end

