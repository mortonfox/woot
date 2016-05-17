#!/usr/bin/env ruby
#
# Woot-off watcher.

require 'open-uri'
require 'rexml/document'
require 'time'
require 'optparse'
require 'ostruct'

$WOOT_URL = 'http://api.woot.com/1/sales/current.rss'

def show_item item
  domain = (item['link'].to_s =~ /^http:\/\/(?:www\.)?([^\/\.]+)/ ? $1 : '')

  soldouttxt = item['woot:soldout']
  soldoutpct = item['woot:soldoutpercentage'].to_f
  soldout = soldouttxt =~ /true/ ? 'Sold Out' : "#{(soldoutpct * 100).to_i}% sold"

  puts '%-12s %-32.32s %7s - %8s - %3s comments' % [ "#{domain}:", item['title'], item['woot:price'], soldout, item['woot:comments'] ]
end

def show_woot
  open($WOOT_URL) { |io|
    doc = REXML::Document.new io
    puts Time.now.strftime '%H:%M:%S'
    doc.elements.collect('rss/channel/item') { |item|
      itemhash = Hash[ item.elements.collect { |elem|
        [ elem.expanded_name, elem.text ]
      } ]
      show_item itemhash
    }
  }
end

def run
  options = OpenStruct.new
  options.sleep = nil

  opts = OptionParser.new { |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
    opts.on('-t', '--update-time N', Integer, 'Time between updates in seconds. This option is useful for watching a Woot-Off. If not specified, just run once and exit.') { |secs|
      if secs <= 0
        warn 'Error parsing command line: -t argument must be greater than 0.'
        warn opts
        exit 1
      end
      options.sleep = secs
    }
    opts.on_tail('-h', '-?', '--help', 'Show this message') {
      puts opts
      exit
    }
  }

  begin
    opts.parse! ARGV
  rescue => err
    warn "Error parsing command line: #{err}"
    warn opts
    exit 1
  end

  if options.sleep
    loop do
      begin
        show_woot
      rescue => err
        warn "Error getting Woot data: #{err}"
      end
      sleep options.sleep
    end
  else
    show_woot
  end
rescue Interrupt
  warn "Interrupted! Exiting..."
end

run

# -- The End --
