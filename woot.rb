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

  puts '%-8s %-36.36s %7s - %8s - %3s comments' % [ "#{domain}:", item['title'], item['woot:price'], soldout, item['woot:comments'] ]
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
  options.sleep = 15

  opts = OptionParser.new { |opts|
    opts.banner = "Usage: #{$0} [options]"
    opts.on('--sleep N', Integer, 'Time between updates in seconds. (default: 15)') { |secs|
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

  loop do
    begin
      show_woot
    rescue => err
      warn "Error getting Woot data: #{err}"
    end
    sleep options.sleep
  end
rescue Interrupt
  warn "Interrupted! Exiting..."
end

run

# -- The End --
