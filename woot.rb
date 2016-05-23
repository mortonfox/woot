#!/usr/bin/env ruby
#
# Woot-off watcher and Woot daily deals summary.

require 'open-uri'
require 'rexml/document'
require 'time'
require 'optparse'
require 'ostruct'

WOOT_URL = 'http://api.woot.com/1/sales/current.rss'.freeze

def show_item item
  soldouttxt = item['woot:soldout']
  soldoutpct = item['woot:soldoutpercentage'].to_f
  soldout = soldouttxt =~ /true/ ? 'Sold Out' : "#{(soldoutpct * 100).to_i}% sold"

  puts format('%-12s %-32.32s %7s - %8s - %3s comments', "#{item['domain']}:", item['title'], item['woot:price'], soldout, item['woot:comments'])
end

def show_woot
  itemhashes = nil
  open(WOOT_URL) { |io|
    result = io.read.gsub('&#x10;', '') # Remove bad XML.
    doc = REXML::Document.new result
    puts Time.now.strftime '%H:%M:%S'
    itemhashes = doc.elements.collect('rss/channel/item') { |item|
      item = Hash[item.elements.collect { |elem|
        [elem.expanded_name, elem.text]
      }]
      item['domain'] = item['link'].to_s =~ %r{^http://(?:www\.)?([^/\.]+)} ? Regexp.last_match(1) : ''
      item
    }
  }
  itemhashes.sort_by { |item| item['domain'] }
    .each { |item| show_item item }
end

def run
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
  warn 'Interrupted! Exiting...'
end

run

__END__
