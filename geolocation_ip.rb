#!/usr/bin/env ruby

# Author: João Pedro Hagen
# Date: 08/09/2023

# Description: We are consuming 2 APIs as one complements the other with better and more accurate features.

require 'net/http'
require 'json'

apiKey1 = '<API_KEY>'
apiKey2 = '<API_KEY>'

print "Enter the IP address you want to query: "
ip_address = gets.chomp.to_s

url1 = URI.parse("https://api.ipgeolocation.io/ipgeo?apiKey=#{apiKey1}&ip=#{ip_address}")
url2 = URI.parse("https://api.ip2location.io/?key=#{apiKey2}&ip=#{ip_address}")

# Make the GET request to the ipgeolocation and ip2location API
response1 = Net::HTTP.get(url1)
response2 = Net::HTTP.get(url2)

# Parse the JSON response if applicable
data1 = JSON.parse(response1)
data2 = JSON.parse(response2)

# Working with the data
output = [
  "\n",
  "IP:             #{data1['ip']}",
  "Continent:      #{data1['continent_name']}",
  "Country:        #{data2['country_name']}",
  "State:          #{data2['region_name']}",
  "City:           #{data2['city_name']}",
  "Postal Code:    #{data2['zip_code']}",
  "Latitude:       #{data2['latitude']}",
  "Longitude:      #{data2['longitude']}",
  "Provider:       #{data1['isp']}",
  "Organization:   #{data1['organization']}"
]

puts output
