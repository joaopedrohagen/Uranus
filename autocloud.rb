#!/usr/bin/env ruby

# Code made by: João Pedro Hagen
# E-mail: joaopedro@hagen.dev.br
# Description: Allows running commands and scripts on batch servers. If you have already added your key to the server,
# you can leave the password as nil in the response method; otherwise, include your password as a string.
# Version: 1.0.0


require 'net/ssh'
require 'net/sftp'


puts '                       /$$                         /$$                           /$$ '
puts '                      | $$                        | $$                          | $$ '
puts '  /$$$$$$  /$$   /$$ /$$$$$$    /$$$$$$   /$$$$$$$| $$  /$$$$$$  /$$   /$$  /$$$$$$$ '
puts ' |____  $$| $$  | $$|_  $$_/   /$$__  $$ /$$_____/| $$ /$$__  $$| $$  | $$ /$$__  $$ '
puts '  /$$$$$$$| $$  | $$  | $$    | $$  \ $$| $$      | $$| $$  \ $$| $$  | $$| $$  | $$ '
puts ' /$$__  $$| $$  | $$  | $$ /$$| $$  | $$| $$      | $$| $$  | $$| $$  | $$| $$  | $$ '
puts '|  $$$$$$$|  $$$$$$/  |  $$$$/|  $$$$$$/|  $$$$$$$| $$|  $$$$$$/|  $$$$$$/|  $$$$$$$ '
puts ' \_______/ \______/    \___/   \______/  \_______/|__/ \______/  \______/  \_______/ '
puts '                                                                                     '
puts '                                                                                     '
puts '                                                                                     '

puts
puts

puts "Hi!"
sleep 1
puts "We will help you execute commands and scripts on batch servers."
sleep 2
puts "Just create a .txt file and add it to the same directory as the script."
sleep 2
puts "Then, change the value of the variable 'archive' to the name of your text file."
sleep 2
puts "Let's get started? =D"


sleep 2

puts

$archive = 'clouds'

$cloud_list = File.readlines($archive).grep(/^ip/)

class Begining
  def user_choice
    print 'Is it a command or a script? [1]Command [2]Script: '
    @choice = gets.chomp.to_i
  end

  def begin
    @choice
  end
end

def response
  choice = Begining.new
  choice.user_choice

  if choice.begin == 1
    print "Enter the commands separated by ';': "
    commands = gets.chomp

    $cloud_list.each do |cloudaccess|
      cloudaccess = cloudaccess.chomp
      puts "Cloud: #{cloudaccess}   Command: #{commands}"

      Net::SSH.start(cloudaccess, 'root', password: nil) do |ssh|
        output = ssh.exec!(commands.to_s)
        puts output
      end

    end

  elsif choice.begin == 2
    print 'Enter the absolute path of the script: '
    script = gets.chomp

    $cloud_list.each do |cloudaccess|
      cloudaccess = cloudaccess.chomp
      puts "Cloud: #{cloudaccess}   Script: #{script}"

      Net::SFTP.start(cloudaccess, 'root', :password => nil) do |sftp|
        sftp.mkdir!('/tmp/autocloud/')
        sftp.upload!(script, '/tmp/autocloud/')
      end

      Net::SSH.start(cloudaccess, 'root', password: nil) do |ssh|
        output = ssh.exec!('/tmp/autocloud/./*.sh')
        ssh.exec!('chmod +x /tmp/autocloud/*.sh')
        puts output
      end

    end

  else
    puts 'Invalid response!'
    response
  end
end

response


sleep 3


puts ' ____   ___  ____  __  ____  ____                                    '
puts '/ ___) / __)(  _ \(  )(  _ \(_  _)                                   '
puts '\___ \( (__  )   / )(  ) __/  )(                                     '
puts '(____/ \___)(__\_)(__)(__)   (__)                                    '
puts ' ____  _  _  _    _  _   __    ___  ____  __ _     ____  ____  _  _  '
puts '(  _ \( \/ )(_)  / )( \ / _\  / __)(  __)(  ( \   (    \(  __)/ )( \ '
puts ' ) _ ( )  /  _   ) __ (/    \( (_ \ ) _) /    / _  ) D ( ) _) \ \/ / '
puts '(____/(__/  (_)  \_)(_/\_/\_/ \___/(____)\_)__)(_)(____/(____) \__/  '
