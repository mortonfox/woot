#!/usr/bin/env ruby

require 'open-uri'
require 'json'

WOOT_URL = 'http://api.woot.com/2/events.json?key=95c1faa8df564b7cb65b681c8b07148d&eventType=Daily'

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

__END__
