require_relative 'ascii_program_interface'

class Crawl
  ITEM_TYPES = {')' => :weapon,'(' => :missle,'[' => :armor,'%' => :food,'?' => :scroll,
    '!' => :potion,'/' => :ward,'=' => :ring,'"' => :amulet,'\\' => :stave,'|' => :rod,
    '+' => :spellbook,':' => :spellbook,'}' => :misc,'$' => :gold}
  KNOWN_OBJECTS = {:ground => ['.'], :walls => ['#'], :creatures => ('a'..'z').to_a,
    :hero => ['@'], :items => ITEM_TYPES.keys}

  def run_program(&block)
    @data = {}
    @interface = AsciiProgramInterface.new('crawl')
    @interface.run_program do
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
    @data[:message] = (screen[-1] || [])

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
    info = {}
    stats = screen.map do |line|
      line[39..-1] if line and line.length > 39
    end
    info[:title] = (stats[0] || '').strip
    info[:title] = '' if info[:title].scan(' the ') == []
    info[:species] = (stats[1] || '').strip
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
