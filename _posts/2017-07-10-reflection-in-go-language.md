---
layout: post
title: "Reflection in Go Language"
date: 2017-07-10 18:11:09 +0800
categories: ['go']
tags: ['go']
---

Go provides a mechnism to update variables and inspect their values at run time, to call their mehtods, and to apply the operations intrinsic to their representation, all without their types at compile time. This mechnism is called *reflection*.

### reflect.Type and reflect.Value

Reflection is provided by the **reflect** package. It defines two important types, **Type** and **Value**. A **Type** represents a Go type. It is an interface with many methods for discriminating among types and inspecting their components, like the fields of a struct or the parameters of a function. The sole implementation of **reflect.Type** is the type decriptor, the same entity that identifies the dynamic type of an interface value.

The **reflect.TypeOf** function accepts any **interface{}** and returns its dynamic type as **reflect.Type**. Becaulse **reflect.TypeOf** returns an interface value's dynamic type, it always returns a concrete type.

```go
	var w io.Writer = os.Stdout
	fmt.Println(reflect.TypeOf(w)) // *os.File
	fmt.Printf("%T\n", w)          // *os.File
```

A **reflect.Value** can hold a value of any type. The **reflect.ValueOf** function accepts any **interface{}** and returns a **reflect.Value** containing the interface's dynamic value.

The inverse operation to **reflect.ValueOf** is the **reflect.Value.Interface** method. It returns an **interface{}** holding the same concrete value as the **reflect.Value**.

```go
	v := reflect.ValueOf(3) // a reflect value
	x := v.Interface()      // an interface{}
	w := x.(int)
	fmt.Println(v)        // 3
	fmt.Printf("%v\n", w) // 3
```

A **reflect.Value** and an **interface{}** can both hold arbitrary values. The difference is that a **Value** has many methods for inspecting its contents, regardless its type.

Although there are infinitely many types, there are only a finite number of ***kinds*** of type: the basic types **Bool**, **String**, and all the numbers; the aggregate types **Array** and **Struct**; the reference types **Chan**, **Func**, **Ptr**, **Slice**, and **Map**; **Interface** types; and finally **Invalid**, meaning no value at all. (The zero value of a **refelect.Value** has kind **Invalid**.)

A variable is an **addressable** storage location that contains a value, and its value may be updated through that address.

A simimar distinction applies to **reflect.Value**s. Some are addressable; others are not.

To recover the variable from an addressable **reflect.Value** requires three steps. First, we call **Addr()**, which returns a **Value** holding a pointer to the variable. Next, we call **Interface()** on this **Value**, which returns an **interface{}** value containing the pointer. Finally, if we know the type of the variable, we can use a type assertion to retrieve the contents of the interface as an oridinary pointer.

```go
	x := 2
	d := reflect.ValueOf(&x).Elem()   // d refers to the variable x
	px := d.Addr().Interface().(*int) // px := &x
	*px = 3                           // x = 3
	fmt.Println(x)                    // "3"
```

We can update the variable referred to by an addressable **reflect.Value** directly, without using a pointer, by calling the **reflect.Value.Set** method:

```go
	d.Set(reflect.ValueOf(4))
	fmt.Println(x) // "4"
	d.SetInt(5)
	fmt.Println(x) // "5"
```

The same checks for assignablility that are oridinarily performed by the compiler are done at runtime by the **Set** methods.

- - -

### References

1. Alan A. A. Donovan, Brian W. Kernighan. The Go Programming Language, 2015.11.
