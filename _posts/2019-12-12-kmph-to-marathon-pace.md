---
layout: post
title: 时速/马拉松配速转换
date: 2019-12-12 16:28:23 +0800
categories: ['Running']
tags: ['Running']
---

```py
#!/usr/bin/env python3

"""
SPEED       PACE        42K     21K
06.0        10'00"      701     330
06.5        09'13"      629     314
07.0        08'34"      601     300
07.5        08'00"      537     248
08.0        07'30"      516     238
08.5        07'03"      457     228
09.0        06'40"      441     220
09.5        06'18"      426     213
10.0        06'00"      413     206
10.5        05'42"      401     200
11.0        05'27"      350     155
11.5        05'13"      340     150
12.0        05'00"      330     145
12.5        04'47"      322     141
13.0        04'36"      314     137
13.5        04'26"      307     133
14.0        04'17"      300     130
14.5        04'08"      254     127
15.0        04'00"      248     124
15.5        03'52"      243     121
16.0        03'45"      238     119
16.5        03'38"      233     116
17.0        03'31"      228     114
17.5        03'25"      224     112
18.0        03'20"      220     110
18.5        03'14"      216     108
19.0        03'09"      213     106
19.5        03'04"      209     104
20.0        03'00"      206     103
20.5        02'55"      203     101
21.0        02'51"      200     100
21.5        02'47"      157     058
22.0        02'43"      155     057
"""
def pace(kmph):
    total_minutes = 60 / kmph
    minutes = total_minutes - (total_minutes - int(total_minutes))
    seconds = int((total_minutes - int(total_minutes)) * 60)
    return "%02d'%02d\"" % (minutes, seconds)

def marathon_time(kmph):
    total_hours = (42.195 / kmph)
    hours = total_hours - (total_hours - int(total_hours))
    minutes = int((total_hours - hours) * 60)
    return '%d%02d' % (hours, minutes)

def half_marathon_time(kmph):
    total_hours = (21.0975 / kmph)
    hours = total_hours - (total_hours - int(total_hours))
    minutes = int((total_hours - hours) * 60)
    return '%d%02d' % (hours, minutes)

print("SPEED\t\tPACE\t\t42K\t\t21K")

for kmph in [km / 10 for km in range(60, 225, 5)]:
    m = pace(kmph)
    t = marathon_time(kmph)
    ht = half_marathon_time(kmph)
    print("%04.1F\t\t%s\t\t%s\t\t%s" % (kmph, m, t, ht))
```
