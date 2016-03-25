---
layout: post
title: "Bubble Sorting with Gopher"
date: 2016-03-25 21-49-16 +0800
categories: [Data Structures,]
tags: ['Data Structures', 'Algorithm', 'Sorting']
---
*bubblesorting.go*
{% highlight python %}
package main

import (
	"fmt"
)

func main() {
	list := []int{49, 38, 65, 97, 76, 13, 27, 49}
	fmt.Printf("%v\n\n", list)
	BubbleSort(list)
	fmt.Printf("\n%v\n", list)
}

func BubbleSort(l []int) {
	length := len(l)
	swap := false
	for i := 0; i < length; i++ {
		for j := 0; j < length-i-1; j++ {
			if l[j] > l[j+1] {
				swap = true
				l[j], l[j+1] = l[j+1], l[j]
			}
		}
		fmt.Printf("%d:%v\n", i, l)
		if !swap {
			break
		}
		swap = false
	}
}
{% endhighlight %}

*output*
{% highlight shell %}
$ go run bubblesorting.go 
[49 38 65 97 76 13 27 49]

0:[38 49 65 76 13 27 49 97]
1:[38 49 65 13 27 49 76 97]
2:[38 49 13 27 49 65 76 97]
3:[38 13 27 49 49 65 76 97]
4:[13 27 38 49 49 65 76 97]
5:[13 27 38 49 49 65 76 97]

[13 27 38 49 49 65 76 97]
{% endhighlight %}
