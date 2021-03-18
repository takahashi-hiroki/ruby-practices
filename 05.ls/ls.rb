# frozen_string_literal: true

require 'etc'

class LsCommand
  def determine_option
    case ARGV[0]
    when nil
      output_either_a_r_or_no_opt(Dir.glob('*').sort)
    when '-a'
      output_either_a_r_or_no_opt(Dir.glob(['.*', '*']).sort)
    when '-r'
      output_either_a_r_or_no_opt(Dir.glob('*').sort.reverse)
    when '-l'
      output_l_or_alr_opt(Dir.glob('*').sort)
    when '-alr', '-arl', '-lra', '-lar', '-ral', '-rla'
      output_l_or_alr_opt(Dir.glob(['.*', '*']).sort.reverse)
    end
  end

  def output_either_a_r_or_no_opt(file)
    @output_file = file
    three_columns.each do |row|
      sum = 0
      row.each do |e|
        printf("%-#{format_number_a_r_or_no_opt}s", e)
        sum += 1
        puts if (sum % 3).zero?
      end
    end
  end

  def three_columns
    first_element, middle_element, last_element =
      @output_file.each_slice(divisor).to_a
    first_element.zip(middle_element, last_element)
  end

  def divisor
    quotient, remainder = @output_file.size.divmod(3)
    remainder.zero? ? quotient : quotient + 1
  end

  def format_number_a_r_or_no_opt
    i = @output_file.max_by(&:size).size
    i + (i % 8) + 6
  end

  def output_l_or_alr_opt(file)
    @output_file = file

    puts "total #{total_blocks}"

    @output_file.each do |e|
      file = File.stat(e.to_s)
      print(
        filetype(file.ftype),
        "#{permission(file)}  ",
        "#{file.nlink} ",
        "#{Etc.getpwuid.name}  ",
        "#{Etc.getgrgid.name}  ",
        "#{file.size}  ",
        "#{format('%s', file.mtime.strftime('%m %d %H:%M'))} ",
        e
      )
      puts
    end
  end

  def total_blocks
    sum = 0
    @output_file.each do |e|
      blocks = File.stat(e.to_s).blocks
      sum += blocks
    end
    sum
  end

  def filetype(file)
    {
      'file' => '-',
      'directory' => 'd',
      'characterSpecial' => 'c',
      'blockSpecial' => 'b',
      'fifo' => 'p',
      'link' => 'l',
      'socket' => 's'
    }[file]
  end

  def permission(file)
    mode = format('%o', file.mode)
    str = ''
    (-3..-1).each do |i|
      str += convert_numbers_to_alphabets(mode[i])
    end
    str
  end

  def convert_numbers_to_alphabets(file)
    {
      '7' => 'rwx',
      '6' => 'rw-',
      '5' => 'r-x',
      '4' => 'r--',
      '3' => '-wx',
      '2' => '-w-',
      '1' => '--x'
    }[file]
  end
end

LsCommand.new.determine_option
