require_relative 'terminal_emulator'
require_relative 'output_parser'

class Crawl
  ITEM_TYPES = {')' => :weapon,'(' => :missle,'[' => :armor,'%' => :food,'?' => :scroll,
    '!' => :potion,'/' => :ward,'=' => :ring,'"' => :amulet,'\\' => :stave,'|' => :rod,
    '+' => :spellbook,':' => :spellbook,'}' => :misc,'$' => :gold}
  KNOWN_OBJECTS = {:ground => ['.'], :walls => ['#'], :creatures => ('a'..'z').to_a,
    :stairs => ['<','>'],:hero => ['@'], :items => ITEM_TYPES.keys}
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

  def parse_screen(output)
    screen = OutputParser.new.parse_input(output)
    {:stats => parse_stats(screen), :visible => parse_visible(screen) }
  end

  def parse_stats(screen)
    panel = screen[0..9].map { |line| line[37..-1] }

    name_and_background = panel[0].split(' the ')
    name = name_and_background[0]
    background = name_and_background[-1]
    species = panel[1].split(' ')[-1]

    notes = (4..7).map { |i| panel[i].split(' ') }
    notes.flatten!
    0.step(16,2) { |i| notes[i] = nil }
    notes.delete(nil)
    ac,str,ev,int,sh,dex,level,exp,place = notes

    branch, floor = place.split(':')

    health = panel[2].split(' ')[1].split('/')
    magic = panel[3].split(' ')[1].split('/')
    weapon = panel[8][7..-1]
    quivered = panel[9][7..-1]

    {:name => name, :species => species, :background => background,
      :health => health, :magic => magic, :ac => ac, :str => str, :ev => ev,
      :int => int, :sh => sh, :dex => dex,:branch => branch, :floor => floor,
      :exp => exp, :floor => floor, :weapon => weapon, :quivered => quivered}
  end

  def parse_visible(screen)
    floor_map = []
    floor_map = screen[0..16].map { |line| line[0..36].split(//) }

    #floor_map.each { |line| p (line || []).join }
    objects = {:hero => [], :creatures => [], :items => [], :stairs => [],
      :walls => [], :ground => [], :map => floor_map.dup}

    floor_map.each_index do |y|
      (floor_map[y] || []).each_index do |x|
        contents = floor_map[y][x]
        KNOWN_OBJECTS.each do |name,abv_array|
          objects[name] << [x,y] if abv_array.include?(contents)
        end
      end
    end
    objects[:hero] = objects[:hero][0]
    objects
  end
end

