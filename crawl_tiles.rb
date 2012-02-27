def handle_read(pipe)
  Thread.current['output'] = ''
  Thread.current['clear'] = false
  until pipe.eof?
    current_char = pipe.getc
    Thread.current['output'] = '' if Thread.current['clear']
    Thread.current['output'] += current_char
    Thread.current['clear'] = false
  end
end

def decipher_output(data)
  string = ''
  is_control_char = false
  output = data[:output]
  (output || '').each_byte do |byte|
    char = byte.chr
    string += char if is_control_char

    if byte == 27
      is_control_char = true
      string = ''
    end

    unless is_control_char
      data = add_character_to_array(data,char,byte)
    end

    if is_control_char and char != char.swapcase
      data = decipher_control_symbol(data,string)
      is_control_char = false
    end
  end
  data
end

def add_character_to_array(data, char, byte)
  if byte == 13
    data[:y] += 2
    data[:x] = 0
  elsif byte == 8
    data[:x] -= 1
    data[:x] = 0 if data[:x] < 0
  elsif byte == 10
    data[:y] += 1
  elsif byte >= 32
    data[:screen][data[:y]] = [] unless data[:screen][data[:y]]
    extra_length = data[:x] - data[:screen][data[:y]].length
    data[:screen][data[:y]] += [' '] * extra_length if extra_length > 0
    data[:screen][data[:y]][data[:x]] = char
    data[:x] += 1
  end
  data
end

def decipher_control_symbol(data, symbol)
  if symbol == '[H'
    data[:y] = 0
    data[:x] = 0
  elsif symbol[-1] == 'H'
    position = symbol[1..-2].split(';')
    data[:y] = position[0].to_i - 1 # I am guessing these aren't zero based
    data[:x] = position[1].to_i - 1
  elsif symbol == '[2J'
    data[:x] = 0
    data[:y] = 0
    data[:screen] = []
  elsif symbol[-1] == 'd'
    distance = symbol[1..-2].to_i
    data[:y] = distance - 1
  elsif symbol == '[C'
    data[:x] +=1
  elsif symbol[-1] == 'C'
    distance = symbol[1..-2].to_i
    data[:x] += distance
  elsif symbol[-1] == 'G'
    distance = symbol[1..-2].to_i
    data[:x] = distance - 1
  end
  data
end

def display_screen(data)
  File.open('screenshot', 'w') do |f|
    (data[:output] || '').each_byte do |byte|
      f.putc(byte)
    end
    f.putc(27)
    f.puts('[20;0H')
  end
end

def write_screen_to_file(data)
  File.open('screen', 'w') do |f|
    data[:screen].each { |line| f.puts (line || []).join  }
  end
end

def parse_screen(data)
  screen = (data[:screen] || []).dup
  data[:message] = (screen[-1] || []).join

  #stats
  data[:stats] = parse_player_stats(screen)

  #map
  floor_map = []
  if screen[0] and screen[0][0..5].join != 'Hello,'
    floor_map = screen[0..12].map do |line|
      line[0..38] if line and line.length >= 38
    end
  end
  data[:floor_map] = floor_map
  data[:objects] = parse_floor_map(floor_map)
  p data[:objects] if floor_map != []
end

def parse_player_stats(screen)
  info = {}
  stats = screen.map do |line|
    line[39..-1].join if line and line.length > 39
  end
  info[:title] = (stats[0] || '').strip
  info[:title] = '' if info[:title].scan(' the ') == []
  info[:species] = (stats[1] || '').strip
  info
end

KNOWN_OBJECTS = {:ground => ['.'], :walls => ['#'], :creatures => ('a'..'z').to_a,
  :hero => ['@'], :items => [')','(','[','%','?','!','/','=','"','\\','|','+',':','}','$']}
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

def make_move(data)
  @last_message = '' unless @last_message
  write_screen_to_file(data) unless @last_message == data[:message]
  @last_message = data[:message]

  if data[:message] == 'What is your name today? '
    data[:move] = ['John', 13]
  elsif data[:message].scan('Which one?') != []
    data[:move] = ['a']
  elsif data[:message].scan('What kind of character are you?') != []
    data[:move] = ['a']
  elsif data[:message].scan('Which weapon?') != []
    data[:move] = ['a']
  elsif data[:stats][:title] != ''
    display_screen(data)
    data[:move] = ['S','Y']
    data[:quit] = true
  end
  data
end

IO.popen("crawl", "w+") do |pipe|
  pipe.flush
  threadA = Thread.fork {handle_read(pipe)}

  data = {:screen => [], :x => 0, :y => 0, :message => '', :move => [], :quit => false, :delay => 0.1}
  while data[:quit] == false
    sleep(data[:delay])
    data[:output] = threadA['output']
    data = decipher_output(data)
    parse_screen(data)
    data = make_move(data)
    if data[:move] != []
      threadA['clear'] = true
      data[:move].each do |move|
        if move.class == String
          pipe.puts(move)
        elsif move.class.to_s == 'FixNum'
          pipe.putc(move)
        end
      end
      data[:move] = []
    end
  end
  `reset`
end
