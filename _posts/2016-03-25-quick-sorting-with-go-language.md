---
layout: post
title: "Quick Sorting with Go language"
date: 2016-03-25 16:38:07 +0800
categories: ['go']
tags: ['algorithm', 'go']
---
*quicksorting.go*
{% highlight go %}
// Quicksort is a divide and conquer algorithm. Quicksort first divides a large array into two smaller sub-arrays: the low elements and the high elements. Quicksort can then recursively sort the sub-arrays. [Wikipedia]
package main

import (
        "fmt"
)

func main() {
        list := []int{49, 38, 65, 97, 76, 13, 27, 49}
        fmt.Println(list)
        fmt.Println(".")
        QuickSort(list)
        fmt.Printf(".\n%v\n", list)
}

// Hoare partition scheme
// The original partition scheme described by C.A.R. Hoare uses two indices that start at the ends of the array being partitioned, then move toward each other, until they detect an inversion: a pair of elements, one greater than or equal to the pivot, one lesser or equal, that are in the wrong order relative to each other. The inverted elements are then swapped. When the indices meet, the algorithm stops and returns the final index. [Wikipedia]
func partition(list []int, low, high int) int {
        p := (low + high) / 2
        pivot := list[p]
        l := low - 1
        h := high + 1
        for {
                for {
                        h = h - 1
                        if list[h] <= pivot {
                                break
                        }
                }
                for {
                        l = l + 1
                        if list[l] >= pivot {
                                break
                        }
                }
                if l >= h {
                        return h
                }
                list[l], list[h] = list[h], list[l]
        }
}

func qSort(list []int, low, high int) {
        if low < high {
                pivotloc := partition(list, low, high)
                fmt.Println(list)
                qSort(list, low, pivotloc)
                qSort(list, pivotloc+1, high)
        }
}

func QuickSort(list []int) {
        qSort(list, 0, len(list)-1)
}

{% endhighlight %}
*output*
{% highlight shell %}
$ go run quicksorting.go

[49 38 65 97 76 13 27 49]
.
[49 38 65 49 76 13 27 97]
[27 38 13 49 76 65 49 97]
[27 13 38 49 76 65 49 97]
[13 27 38 49 76 65 49 97]
[13 27 38 49 76 65 49 97]
[13 27 38 49 49 65 76 97]
[13 27 38 49 49 65 76 97]
.
[13 27 38 49 49 65 76 97]
{% endhighlight %}
