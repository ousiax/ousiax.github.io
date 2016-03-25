---
layout: post
title: "Quick Sorting with Gopher"
date: 2016-03-25 16-38-07 +0800
categories: Data Structures
---
*quicksorting.go*
{% highlight go %}
package main

import (
	"fmt"
)

func main() {
	list := []int{49, 38, 65, 97, 76, 13, 27, 49}
	fmt.Println(list)
	QuickSort(list)
	fmt.Println()
	fmt.Println(list)
}

func partition(l []int, low, high int) int {
	pivotkey := l[low]
	for low < high {
		for low < high && l[high] >= pivotkey {
			high = high - 1
		}
		l[low], l[high] = l[high], l[low]
		for low < high && l[low] <= pivotkey {
			low = low + 1
		}
		l[low], l[high] = l[high], l[low]
	}
	return low
}

func qSort(l []int, low, high int) {
	if low < high {
		pivotloc := partition(l, low, high)
		fmt.Println(l)
		qSort(l, low, pivotloc-1)
		qSort(l, pivotloc+1, high)
	}
}

func QuickSort(l []int) {
	qSort(l, 0, len(l)-1)
}
{% endhighlight %}
*output*
{% highlight shell %}
$ go run quicksorting.go
[49 38 65 97 76 13 27 49]
[27 38 13 49 76 97 65 49]
[13 27 38 49 76 97 65 49]
[13 27 38 49 49 65 76 97]
[13 27 38 49 49 65 76 97]

[13 27 38 49 49 65 76 97]
{% endhighlight %}
