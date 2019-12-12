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
时速        配速        42K
06.0        10'00''     701
06.5        09'13''     629
07.0        08'34''     601
07.5        08'00''     537
08.0        07'30''     516
08.5        07'03''     457
09.0        06'40''     441
09.5        06'18''     426
10.0        06'00''     413
10.5        05'42''     401
11.0        05'27''     350
11.5        05'13''     340
12.0        05'00''     330
12.5        04'47''     322
13.0        04'36''     314
13.5        04'26''     307
14.0        04'17''     300
14.5        04'08''     254
15.0        04'00''     248
15.5        03'52''     243
16.0        03'45''     238
16.5        03'38''     233
17.0        03'31''     228
17.5        03'25''     224
18.0        03'20''     220
18.5        03'14''     216
19.0        03'09''     213
19.5        03'04''     209
20.0        03'00''     206
"""
def pace(kmph):
    total_minutes = 60 / kmph
    minutes = total_minutes - (total_minutes - int(total_minutes))
    seconds = int((total_minutes - int(total_minutes)) * 60)
    return "%02d'%02d''" % (minutes, seconds)

def marathon_time(kmph):
    total_hours = (42.195 / kmph)
    hours = total_hours - (total_hours - int(total_hours))
    minutes = int((total_hours - hours) * 60)
    return '%d%02d' % (hours, minutes)

print("时速\t\t配速\t\t42K")
for kmph in [km / 10 for km in range(60, 205, 5)]:
    m = pace(kmph)
    t = marathon_time(kmph)
    print("%04.1F\t\t%s\t\t%s" % (kmph, m, t))
```
