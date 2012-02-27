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
  output.each_byte do |byte|
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
  data[:screen].each { |line| p (line || []).join  }
end

def write_screen_to_file(data)
  File.open('screen', 'w') do |f|
    data[:screen].each { |line| f.puts (line || []).join  }
  end
end

IO.popen("crawl", "w+") do |pipe|
  pipe.flush
  threadA = Thread.fork {handle_read(pipe)}

  data = {:screen => [], :x => 0, :y => 0}
  5.times do |i|
    sleep(2)
    p data[:output] = threadA['output'], i
    data = decipher_output(data)
    threadA['clear'] = true
    if i == 0 #'What is your name today?') != []
      pipe.puts('John')
      pipe.putc(13)
    elsif data[:output].scan('must be new here') != []
      2.times do
        pipe.putc('a')
        sleep(2)
        threadA['clear'] = true
      end
      pipe.putc('a')
    else
      write_screen_to_file(data)
      pipe.putc('S')      #pipe.putc('q')
      pipe.putc('Y')
      5.times { pipe.putc(13) }
      break
    end
  end
end
