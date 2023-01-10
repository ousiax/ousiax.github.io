#!/usr/bin/env ruby
# -*- encoding:utf-8 -*-
#
# The MIT License (MIT)
# 
# Copyright (c) 2018 ROY XU <qqbuby@gmail.com>
#
# Description: Create a jekyll post file named 'yyyy-MM-dd-title.adoc' with front matter.
#
# Usage:
# $ ./jekyll-post.rb -t 'Hello World' -c "Hello, World"
#$ cat 2021-08-27-hello-world.adoc 
# = Hello World
# :page-layout: post
# :page-categories: [Hello, World]
# :page-tags: [Hello, World]
# :revdate: 2021-08-27 18:11:04 +0800
#
#

require 'optparse'
require 'date'
require 'securerandom'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: post.rb [options]"
    opts.on('-t', '--title title', 'The title of the post') { |t| options[:title] = t }
    opts.on('-c', '--category [\'category1\', \'category2\', .., \'categoryN\']', 'The category of the post') { |c| options[:category] = c }
    opts.on('-f', '--filename filename', 'The file name of the post without date, default is \'--title\'') { |f| options[:filename] = f }
    opts.on('--tag [\'tag1\', \'tag2\', .., \'tagN\']', 'The tags of the post') { |tag| options[:tag] = tag }
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
filename = date.strftime('%Y-%m-%d') + '-' + filename + ".adoc"
revdate = date.strftime('%Y-%m-%d %H:%M:%S %z')

front_matter = "= #{title}\n" \
  ":page-layout: post\n" \
  ":page-categories: [#{categories}]\n" \
  ":page-tags: [#{tags}]\n" \
  ":page-date: #{revdate}\n" \
  ":page-revdate: #{revdate}\n" \
  ":toc: preamble\n" \
  ":toclevels: 4\n" \
  ":sectnums:\n" \
  ":sectnumlevels: 4\n" \
  "\n"

File.open(filename, 'w') { |f| f.write(front_matter) }

__END__
