#!/usr/bin/env ruby
#
# Woot-off watcher and Woot daily deals summary.
# Uses Woot API v2 beta.

require 'open-uri'
require 'json'
require 'time'
require 'optparse'
require 'ostruct'

WOOT_URL = 'http://api.woot.com/2/events.json?key=95c1faa8df564b7cb65b681c8b07148d&eventType=Daily'.freeze
WOOTOFF_URL = 'http://api.woot.com/2/events.json?key=95c1faa8df564b7cb65b681c8b07148d&eventType=WootOff'.freeze

def offers url
  open(url) { |io|
    results = JSON.parse(io.read)
    Hash[
      results.map { |res|
        domain = res['Site'].split('.').first
        domain = 'woot' if domain == 'www'
        offer = res['Offers'].first
        [domain, offer]
      }
    ]
  }
end

def show_woot domain, offer
  soldout = offer['SoldOut'] ? 'Sold Out' : "#{format('%.0f', 100 - offer['PercentageRemaining'])}% sold"
  price = '$' + format('%.2f', offer['Items'].first['SalePrice'])
  puts format('%-11s %-46.46s %8s - %8s', domain, offer['Title'], price, soldout)
end

def show_woot_list woot_list
  woot_list.keys.sort.each { |domain|
    show_woot domain, woot_list[domain]
  }
end

def show_woots
  show_woot_list(offers(WOOT_URL))

  wootoff_list = offers WOOTOFF_URL
  unless wootoff_list.empty?
    puts "\n=== Woot-Off! ==="
    show_woot_list wootoff_list
  end
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

def run
  options = parse_cmdline

  if options.sleep
    loop do
      begin
        puts Time.now.strftime '%H:%M:%S'
        show_woots
      rescue => err
        warn "Error getting Woot data: #{err}"
      end
      sleep options.sleep
    end
  else
    show_woots
  end
rescue Interrupt
  puts 'Interrupted! Exiting...'
end

run

__END__
