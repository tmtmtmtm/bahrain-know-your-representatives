#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//p[strong[contains(.,"Profiles of other Bahrain MPs")]]/following-sibling::p[strong]').each do |p|
    name, area = p.text.tidy.split(/ [\-–] /, 2)
    data = {
      name:   name,
      area:   area,
      term:   2014,
      source: p.xpath('following-sibling::p[a]/a/@href').first.text,
    }
    %i[source].each { |i| data[i] = URI.join(url, URI.encode(data[i])).to_s unless data[i].to_s.empty? }
    puts data.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h if ENV['MORPH_DEBUG']
    ScraperWiki.save_sqlite(%i[name area term], data)
  end
end

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
scrape_list('https://www.citizensforbahrain.com/index.php/entry/know-your-deputy-jamila-al-sammak-12th-northern')
