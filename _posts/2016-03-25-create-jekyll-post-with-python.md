---
disqus_identifier: 336505236916646378554443448103515918249
layout: post
title: "Create Jekyll Post with Python"
date: 2016-03-25 15-43-01 +0800
categories: ['Python',]
tags: ['Python', 'Jekyll',]
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
import uuid

def main():
    parser = argparse.ArgumentParser(description='Jekyll Post')
    parser.add_argument('title', help='The title of the post.')
    parser.add_argument('category', help='The categores of the post.')
    parser.add_argument('--tag', help='The tags of the post.')
    args = parser.parse_args()
    
    title = args.title
    categories = args.category
    tags = args.tag if args.tag else args.category

    name, date = time.strftime('%Y-%m-%d') + '-' + title.replace(' ','-') + '.md', time.strftime('%Y-%m-%d %H-%M-%S %z')

    disqus_identifier = uuid.uuid4().int

    yaml = '''---
layout: post
title: "%s"
date: %s
categories: %s
tags: %s
disqus_identifier: %d
---'''
    post = yaml % (title, date, categories, tags, disqus_identifier)
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
$ python jekyll-post.py "foo bar" "['hello','world']"
$ cat 2016-03-29-foo-bar.md 
---
layout: post
title: "foo bar"
date: 2016-03-29 19-39-52 +0800
categories: ['hello','world']
tags: ['hello','world']
disqus_identifier: 199975908006844180551570514566123396410
---
{% endhighlight %}

