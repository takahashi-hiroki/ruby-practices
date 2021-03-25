# frozen_string_literal: true

require 'etc'

class LsCommand
  def determine_option
    argv = ARGV[0]

    files =
      argv&.include?('a') ? Dir.glob(['.*', '*']).sort : Dir.glob('*').sort

    files = files.reverse if argv&.include?('r')

    argv&.include?('l') ? found_l_opt(files) : not_found_l_opt(files)
  end

  def not_found_l_opt(files)
    @output_files = files
    @output_files.size <= 2 ? output_of_two_or_fewer_files : output_three_or_more_files
  end

  def output_of_two_or_fewer_files
    @output_files.each { |e| printf("%-#{format_number_a_r_or_no_opt}s", e) }
    puts
  end

  def format_number_a_r_or_no_opt
    i = @output_files.max_by(&:size).size
    i + (i % 8) + 6
  end

  def output_three_or_more_files
    three_columns.each do |row|
      row.each.with_index(1) do |e, i|
        printf("%-#{format_number_a_r_or_no_opt}s", e)
        puts if (i % 3).zero?
      end
    end
  end

  def three_columns
    first_element, middle_element, last_element =
      @output_files.each_slice(divisor).to_a
    first_element.zip(middle_element, last_element)
  end

  def divisor
    quotient, remainder = @output_files.size.divmod(3)
    remainder.zero? ? quotient : quotient + 1
  end

  def found_l_opt(files)
    @output_files = files

    puts "total #{total_blocks}"

    @output_files.each do |e|
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
    @output_files.sum do |e|
      File.stat(e.to_s).blocks
    end
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
