---
layout: post
title: Pandoc Convert Markdown to PDF
date: 2019-09-03 15:38:00 +0800
categories: ['pandoc']
tags: ['pandoc', 'pdf']
---

```sh
$ fc-list :lang=zh-cn # list chinese fonts
/usr/share/fonts/truetype/arphic-gkai00mp/gkai00mp.ttf: AR PL KaitiM GB,文鼎ＰＬ简中楷:style=Regular
$ fc-scan /usr/share/fonts/truetype/arphic-gkai00mp/gkai00mp.ttf
Pattern has 24 elts (size 32)
    family: "AR PL KaitiM GB"(s) "文鼎ＰＬ简中楷"(s)
    familylang: "zh-tw"(s) "zh-cn"(s)
    style: "Regular"(s)
    stylelang: "zh-tw"(s)
    fullname: "AR PL KaitiM GB"(s) "文鼎ＰＬ简中楷"(s)
    fullnamelang: "zh-tw"(s) "zh-cn"(s)
    slant: 0(i)(s)
    weight: 80(f)(s)
    width: 100(f)(s)
    spacing: 90(i)(s)
    foundry: "ARPH"(s)
    file: "/usr/share/fonts/truetype/arphic-gkai00mp/gkai00mp.ttf"(s)
$ pandoc README.md --pdf-engine=xelatex -V CJKmainfont="AR PL KaitiM GB" -o x.pdf
```
