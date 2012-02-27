require_relative 'terminal_emulator'

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
    @data = {}
    @interface = TerminalEmulator.new
    @interface.run_program('crawl' + @cmd_arguements) do
      @interface.take_screen_shot
      parse_screen
      block.call(@data)
    end
  end

  def take_screen_shot
    @interface.take_screen_shot
  end

  def display_screen
    @interface.display_screen
  end

  def press_buttons(input)
    @interface.press_buttons(input)
  end

  def stop_program
    @interface.stop_program
  end

  def parse_screen
    screen = @interface.get_screen_contents
    @data[:screen] = screen
    p @data[:message] = (screen[-1] || [])

    #stats
    @data[:stats] = parse_player_stats(screen)

    #map
    floor_map = []
    if screen[0] and screen[0][0..5] != 'Hello,'
      floor_map = screen[0..12].map do |line|
        line[0..38].split(//) if line and line.length >= 38
      end
    end
    @data[:floor_map] = floor_map
    @data[:objects] = parse_floor_map(floor_map)
    #p @data[:objects] if floor_map != []
  end

  def parse_player_stats(screen)
    return unless screen[0]
    return if screen[0].strip.scan(' the ') == []
    info = {}
    stats = screen.map do |line|
      line[37..-1] if line and line.length > 39
    end
    info[:title] = (stats[0] || '').strip
    info[:title] = '' if info[:title].scan(' the ') == []
    info[:species] = (stats[1] || '').strip
    magic = (stats[3] || '').split(' ')[1]
    info[:magic_remaining] = magic.split('/')[0].to_i if magic
    info
  end

  def parse_floor_map(floor_map)
    objects = {:hero => [], :creatures => [], :items => [],
      :stairs => [], :walls => [], :ground => []}

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
