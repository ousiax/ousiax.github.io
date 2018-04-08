#!/usr/bin/env ruby
# -*- encoding:utf-8 -*-
#
# The MIT License (MIT)
# 
# Copyright (c) 2018 ROY XU <qqbuby@gmail.com>
#
# Description: Create a jekyll post file named 'yyyy-MM-dd-title.md' with front matter.
#
# Usage:
# $ ./jekyll-post.rb -t 'Hello World' -c "['Hello', 'World']"
# $ cat 2018-04-06-hello-world.md
# ---
# layout: post
# title: Hello World
# date: 2018-04-06 14:27:23 +0800
# categories: ['Hello', 'World']
# tags: ['Hello', 'World']
# disqus_identifier: 80366368515793348026083669683423237092
# ---

require 'optparse'
require 'date'
require 'securerandom'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: post.rb [options]"
    opts.on('-t', '--title title', 'The title of the post') { |t| options[:title] = t }
    opts.on('-c', '--category [\'category1\', \'category2\', .., \'categoryN\']', 'The category of the post') { |c| options[:category] = c }
    opts.on('-f', '--filename filename', 'The file name of the post without date, default is \'--title\'') { |f| options[:filename] = f }
    opts.on('--tag [\'tag1\', \'tag2\', .., \'tagN\']', 'The tags of the post') { |tag| options[:tag] = o }
    opts.on('-h', '--help', 'Show this help message and exit')  do
        puts opts
        exit
    end
end.parse!

raise "require the title of the post, '--title'" unless options[:title]
raise "require the title of the post, '--category'" unless options[:category]

title = options[:title]
categories = options[:category]
tags = options[:tag]
unless tags 
    tags = categories
end

filename = options[:filename]
unless filename 
    filename = title.dup
end

date = DateTime.now
disqus_identifier = SecureRandom::uuid.gsub('-','').hex

filename = filename.gsub(' ', '-').gsub(/\(|\)|\./, '').downcase
filename = date.strftime('%Y-%m-%d') + '-' + filename + ".md"
date = date.strftime('%Y-%m-%d %H:%M:%S %z')

front_matter = "---\nlayout: post\ntitle: #{title}\ndate: #{date}\ncategories: #{categories}\ntags: #{tags}\ndisqus_identifier: #{disqus_identifier}\n---"

File.open(filename, 'w') { |f| f.write(front_matter) }

__END__
