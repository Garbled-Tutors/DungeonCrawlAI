class OutputParser
  INACTIVE = nil
  ESCAPE_BYTE = 27

  def reset_screen
    @x = 0
    @y = 0
    @screen = []
    @escape_code = INACTIVE
  end

  def display_screen(all_input)
    reset_screen
    parse_input(all_input)
    get_screen_contents.each { |line| puts line }
  end

  private
  def get_screen_contents
    @screen.dup.map do |line|
      (line || []).map { |char| char || ' ' }.join
    end
  end

  def parse_input(input)
    input.each_byte do |byte|
      write_byte_to_screen(byte) if @escape_code == INACTIVE
      read_for_escape_codes(byte)
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

  def write_byte_to_screen(byte)
    if byte == 13
      @y += 2
      @x = 0
    elsif byte == 8
      @x -= 1
      @x = 0 if @x < 0
    elsif byte == 10
      @y += 1
    elsif byte >= 32
      @screen[@y] = [] unless @screen[@y]
      @screen[@y][@x] = byte.chr
      @x += 1
    end
  end

  def handle_escape_code
    if @escape_code == '[H'
      @y = 0
      @x = 0
    elsif @escape_code == '[2J'
      reset_screen
    elsif @escape_code[-1] == 'H'
      position = @escape_code[1..-2].split(';')
      @y = position[0].to_i - 1
      @x = position[1].to_i - 1
    elsif @escape_code[-1] == 'd'
      distance = @escape_code[1..-2].to_i
      @y = distance - 1
    elsif @escape_code == '[C'
      @x +=1
    elsif @escape_code[-1] == 'C'
      distance = @escape_code[1..-2].to_i
      @x += distance
    elsif @escape_code[-1] == 'G'
      distance = @escape_code[1..-2].to_i
      @x = distance - 1
    end
  end
end
