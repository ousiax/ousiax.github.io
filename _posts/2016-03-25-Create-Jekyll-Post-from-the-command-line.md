---
layout: post
title: "Create Jekyll Post from the command line"
date: 2016-03-25 15-43-01 +0800
categories: Jekyll
tags: Jekyll
---
*Jekyll-post.py*
{% highlight python %}
#!/usr/bin/env python
# -*- encoding:utf-8 -*-

# The MIT License (MIT)
#
# Copyright (c) 2016 Roy Xu

import argparse
import time

def main():
    parser = argparse.ArgumentParser(description='Jekyll Post')
    parser.add_argument('title', help='The title of the post.')
    parser.add_argument('category', help='The categores of the post.')
    args = parser.parse_args()
    
    title = args.title
    categories = args.category

    name, date = time.strftime('%Y-%m-%d') + '-' + title.replace(' ','-') + '.md', time.strftime('%Y-%m-%d %H-%M-%S %z')

    yaml = '---\nlayout: post\ntitle: "%s"\ndate: %s\ncategories: %s\n---\n'
    post = yaml % (title, date, categories)
    fp = None
    try:
        fp = open(name, 'w')
        fp.write(post)
    finally:
        if fp:
            fp.close()

if __name__ == '__main__':
    main()
{% endhighlight %}

*Usage*
{% highlight shell %}
$ jekyll-post.py "Create Jekyll Post from the command line" "Jekyll"
$ ls
2016-03-25-Create-Jekyll-Post-from-the-command-line.md
$ cat 2016-03-25-Create-Jekyll-Post-from-the-command-line.md
---
layout: post
title: "Create Jekyll Post from the command line"
date: 2016-03-25 15-43-42 +0800
categories: Jekyll
---
{% endhighlight %}

