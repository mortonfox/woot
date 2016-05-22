#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'time'
require 'optparse'
require 'ostruct'

WOOT_URL = 'http://api.woot.com/2/events.json?key=95c1faa8df564b7cb65b681c8b07148d&eventType=Daily'.freeze

def show_woot
  open(WOOT_URL) { |io|
    results = JSON.parse(io.read)

    results.sort_by { |res| res['Site'] }.each { |res|
      domain = res['Site'].split('.').first
      domain = 'woot' if domain == 'www'
      offer = res['Offers'].first
      soldout = offer['SoldOut'] ? 'Sold Out' : "#{format('%.0f', 100 - offer['PercentageRemaining'])}% sold"
      price = '$' + format('%.2f', offer['Items'].first['SalePrice'])

      puts format('%-11s %-46.46s %8s - %8s', domain, res['Title'], price, soldout)
    }
  }
end

def parse_cmdline
  options = OpenStruct.new sleep: nil

  opts = OptionParser.new

  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

  opts.on('-t', '--update-time N', Integer, 'Time between updates in seconds. This option is useful for watching a Woot-Off. If not specified, just run once and exit.') { |secs|
    if secs <= 0
      warn 'Error parsing command line: -t argument must be greater than 0.'
      warn opts
      exit 1
    end
    options.sleep = secs
  }

  opts.on('-h', '-?', '--help', 'Show this message') {
    puts opts
    exit
  }

  begin
    opts.parse! ARGV
  rescue => err
    warn "Error parsing command line: #{err}"
    warn opts
    exit 1
  end

  options
end

options = parse_cmdline

if options.sleep
  begin
    loop do
      puts Time.now.strftime '%H:%M:%S'
      show_woot
      sleep options.sleep
    end
  rescue Interrupt
    puts 'Interrupted! Exiting...'
  end
else
  show_woot
end

__END__
