# frozen_string_literal: true

class WcCommand
  require 'optparse'

  attr_reader :options

  def initialize
    description =
      'The number of lines in each input file is written to the standard out-put.'
    @options = {}
    OptionParser.new do |o|
      o.on('-l', '--lines File', description.to_s) { |v| @options[:l] = [v] }
      o.on('-h', '--help', 'show this help') { |_v| puts o; exit }
      o.parse!(ARGV)
    end
  end

  def standard_input_or_other
    if $stdin.tty?
      options.key?(:l) ? l_option : no_option
    else
      input_from_pipe
    end
  end

  def l_option
    puts 'l_option'
  end

  def no_option
    puts 'no_option'
  end

  def input_from_pipe
    puts 'input_from_pipe'
  end
end

wc = WcCommand.new
wc.standard_input_or_other
