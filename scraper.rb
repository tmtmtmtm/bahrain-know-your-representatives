#!/bin/env ruby
# encoding: utf-8

require 'nokogiri'
require 'pry'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//p[strong[contains(.,"Profiles of other Bahrain MPs")]]/following-sibling::p[strong]').each do |p|
    name, area = p.text.tidy.split(/ [\-–] /, 2)
    data = { 
      name: name,
      area: area,
      term: 2014,
      source: p.xpath('following-sibling::p[a]/a/@href').first.text,
    }
    %i(source).each { |i| data[i] = URI.join(url, URI.encode(data[i])).to_s unless data[i].to_s.empty? }
    ScraperWiki.save_sqlite([:name, :area, :term], data)
  end
end

scrape_list('http://www.citizensforbahrain.com/index.php/entry/know-your-deputy-jamila-al-sammak-12th-northern')
