class OutputParser
  INACTIVE = nil
  ESCAPE_BYTE = 27
  CURSOR_MOVEMENT_ESCAPE_CHARS = ['H', 'J']

  def reset_buffer
    @x = 0
    @y = 0
    @buffer = []
    @escape_code = INACTIVE
  end

  def initialize
    reset_buffer
  end

  def display_screen(all_input)
    reset_buffer
    parse_input(all_input).each { |line| puts line }
  end

  def parse_input(input)
    input.each_byte do |byte|
      write_byte_to_buffer(byte) if @escape_code == INACTIVE
      read_for_escape_codes(byte)
    end
    get_buffer_contents
  end

  def find_colored_portions(input, color_code)
    p input
    characters_found = []
    input.each_byte do |byte|
      if @escape_code == INACTIVE
        write_byte_to_buffer(byte)
      elsif color_code == @escape_code.to_s + byte.chr
        characters_found << [@x,@y]
      end
      read_for_escape_codes(byte)
    end
    {:screen => get_buffer_contents, :results => characters_found }
  end

  def seperate_by_cursor_jumps(input)
    results = [ [@y,@x] ]
    input.each_byte do |byte|
      if @escape_code == INACTIVE
        write_byte_to_buffer(byte)
      elsif CURSOR_MOVEMENT_ESCAPE_CHARS.include?(byte.chr)
        @buffer = get_buffer_contents.map { |line| line.strip }
        @buffer.delete('')
        if @buffer != []
          results[-1][2] = @buffer
          results << get_cursor_position_after_escape(@escape_code + byte.chr)
        end
        @buffer = []
      end
      read_for_escape_codes(byte)
    end
    results
  end

  private
  def get_buffer_contents
    @buffer.dup.map do |line|
      (line || []).map { |char| char || ' ' }.join
    end
  end

  def read_for_escape_codes(byte)
    char = byte.chr
    @escape_code += char if @escape_code != INACTIVE
    @escape_code = '' if byte == ESCAPE_BYTE

    byte_is_letter = char != char.swapcase
    if @escape_code != INACTIVE and byte_is_letter
      handle_escape_code
      @escape_code = INACTIVE
    end
  end

  def write_byte_to_buffer(byte)
    if byte == 13
      @y += 2
      @x = 0
    elsif byte == 8
      @x -= 1
      @x = 0 if @x < 0
    elsif byte == 10
      @y += 1
    elsif byte >= 32
      @buffer[@y] = [] unless @buffer[@y]
      @buffer[@y][@x] = byte.chr
      @x += 1
    end
  end

  def get_cursor_position_after_escape(escape_code)
    return [@y, @x] unless escape_code
    if escape_code == '[H' or escape_code == '[2J'
      [0, 0]
    elsif escape_code[-1] == 'H'
      position = escape_code[1..-2].split(';')
      [position[0].to_i - 1,  position[1].to_i - 1]
    elsif escape_code[-1] == 'd'
      distance = escape_code[1..-2].to_i
      [distance - 1, @x]
    elsif escape_code == '[C'
      [@y, @x + 1]
    elsif escape_code[-1] == 'C'
      distance = escape_code[1..-2].to_i
      [@y, @x + distance]
    elsif escape_code[-1] == 'G'
      distance = escape_code[1..-2].to_i
      [@y, distance - 1]
    else
      [@y, @x]
    end
  end

  def handle_escape_code
    if @escape_code == '[2J'
      reset_buffer
    elsif @escape_code == '[2S'
      @buffer[@y] = []
    elsif @escape_code == '[J'
      @buffer = @buffer[0..@y]
      @buffer[@y] = @buffer[@y][0..@x] if @buffer[@y]
      @buffer[@y][@x] = ' ' if @buffer[@y]
    else
      #p @escape_code
    end
    @y, @x = get_cursor_position_after_escape(@escape_code)
  end
end
