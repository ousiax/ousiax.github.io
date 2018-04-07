---
layout: post
title: "Pointers in C Language"
date: 2017-03-02 17:19:51 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 186579721564951921087832385494630209132
---

* TOC
{:toc}

- - -

Pointers hold memory address of stored constants or variables. For any data type, including both primitive types and custom types, you can create a pointer that holds the memory address of an instance of that type.

### 1. Declaring Pointers

You declare a pointer by specifying a name for it and a data type. The data type indicates of what type of variable the pointer will hold memory addresses.

To declare a pointer, include the **indirection operator** before the identifier. Here is the general form of a pointer declaration:

```c
data-type * name;
```

White space is not significant around the indirection operator:

```c
data-type *name;
data-type* name;
```

Here is an example of declaring a pointer to hold the address of an `int` variable:

```c
int *ip;
```

Be careful, though: when declaring multiple pointers in the same statement, you must explicitly declare each as a pointer, using the indirection operator:

```c
int *foo, *bar;     /* Two pointers. */
int *baz, quux;     /* A pointer and an integer variable. */
```

### 2. Intializing Pointers

You can initialize a pointer when you first declare it by specifying a variable address to store in it. For example, the following code declares an `int` variable `i`, and a pointer which is initialized with the address of `i`:

```c
int i;
int *p = &i;
```

Note the use of the **address operator**, used to get the memory address of a variable. After you declare a pointer, you do *not* use the indirection operator with the pointer's name when assigning it a new address to point to. On the countrary, that would change the value of the variable that the points to, not the value of the ponter itself. For example:

```c
int i, j;
int *ip = &i;  /* ‘ip’ now holds the address of ‘i’. */
ip = &j;       /* ‘ip’ now holds the address of ‘j’. */
*ip = &i;      /* ‘j’ now holds the address of ‘i’. */
```

The value stored in a pointer is an integral number: a location within the computer's memory space. If you are so inclined, you can assign pointer values explicitly using literal integers, casting them to the appropriate pointer type. However, we do not recommend this practice unless you need to have extremely fine-tuned control over what is stored in memory, and you known exactly what are doing. It would be all too easy to accidentally overwrite something that you did not intend to. Most uses of this technique are also non-portable.

It is important to note thant if you do not initialize a pointer with the address of some other existing object, it points nowhere in particular and will likely make your program crash if you use it (formmally, this kind of thing is called *undefined behavior*).

### 3. Pointers to Unions

You can create a pointer to a union type just as you can a pointer to a primitive data type.

```c
union numbers {
    int i;
    float f;
};
union numbers foo = { 4 };
union numbers *number_ptr = &foo;
```

That example creates a new union type, `union numbers`, and declares ( and initializes the first member of) a variable of that type named `foo`. Finally, it declares a pointer to the type `union numbers`, and gives it th address of `foo`.

You can access the members of a union variable through a pointer, but you can't use the regular **member access operator** anymore. Instead, you have to use the **indirect member access operator**. Continuing with the previous example, the following example will change the value of the first member of `foo`:

```c
number_ptr -> i = 450;
```

Now the `i` member in `foo` is 450.

### 4. Pointers to Structures

You can create a pointer to a structure type just as you can a pointer to a primitive data type.

```c
struct fish {
    float length, weight;
};
struct fish salmon = { 4.3, 5.8 };
struct fish *fish_prt = &salmon;
```

That example creates a new structure type, `struct fish`, and declares (and initializes) a variable of that type named `salmon`.

You can access the members of a structure variable through a pointer, but you can't use the regular **memeber access operator** anymore. Instead, you have to use the **indirect member access operator**. Continuing with the previous example, the following example will change the values of the members of `salmon`:

```c
fish_ptr -> length = 5.1;
fish_ptr -> weight = 6.2;
```

Now the `length` and `width` members in `salmon` are 5.1 and 6.2, respectively.

### 5. Dangling, Void , Null and Wild Pointers

- **Dangling Pointer**

    A pointer pointing to a memory location that has been deleted (or freed) is called dangling pointer. There are three different ways where Pointer acts as dangling pointer.

    - ***De-allocation of memory***

    ```c
    // Deallocating a memory address by ptr causes dangling pointer
    #include <stdio.h>
    #include <stdlib.h>
    
    int main(void)
    {
        int *ptr = (int*)malloc(sizeof(int));

        // After below free call, ptr becomes a dangling pointer
        free(ptr);

        // No more a dangling pointer
        ptr = NULL;
    }
    ```

    - ***Function Call***

        ```c
        // The pointer poiting to local variable becomes
        // dangling when local variable is not static.
        #include <stdio.h>
        
        int *fun()
        {
            // x is local variable and goes out of
            // scope after an execution of fun() is
            // over.
            int x = 5;
            return &x;
        }
        
        // Driver Code
        int main(void)
        {
            int *p = fun();
            fflush(stdin);
            // p points to something which is not
            // valid anymore
            printf("%p -> %d\n", p, *p);
            return 0;
        }
        ```

        The above problem doesn't appear (or p doesn't become dangling) if `x` is a static vairable.

        ```c
        // The pointer poiting to local variable doesn't become
        // dangling when local variable is static.
        #include <stdio.h>
        
        int *fun()
        {
            // x now has scope througout the program
            static int x = 5;
            return &x;
        }
        
        int main()
        {
            int *p = fun();
            fflush(stdin);
            // Not a dangling pointer as it points to static variable.
            printf("%p -> %d\n", p, *p);
            return 0;
        }
        ```

        - ***Variable goes out of scope***

        ```c
        void main(void)
        {
            int *ptr;
            // ...
            // ...
            {
                int ch;
                ptr = &ch;
            }
            // ...
            // Here ptr is dangling pointer
        }
        ```

- **Void pointer**

    Void pointer is a specific pointer type (`void *`), a pointer that points to some data location in storage, which doesn't have any specific type. Void refers to the type. Basically the type of data that it points to is can be any. If we assign address of char data type to void pointer it will become char Pointer, if int data type then int pointer and so on. Any pointer type is convertible to a void pointer hence it can point to any value.

    ***Important Points***

    - void pointers **cannot be dereferenced**. It can however be done using typecasting the void pointer.

    - Pointer arithmetic is not possible on pointers of void due to lack of concrete value and thus size.

    - `malloc()` and `calloc()` return void \* type and this allows these functions to be used to allocate memory of any data type (just because of void \*)

    - void pointer in C are used to implement generic funciton in C.

    ```c
    #include <stdio.h>
    
    int main(void)
    {
        int x = 4;
        float y = 5.5;
        // A void pointer
        void *ptr;
        ptr = &x;
        // (int*)ptr - does type casting of void
        // *((int*)ptr) dereferences the typecasted void pointer variable
        printf("Integer variable is %d\n", *((int *)ptr));
        // void pointer is now float
        ptr = &y;
        printf("Float variable is %f\n", *((float *)ptr));
        return 0;
    }
    ```

- **NULL Pointer**

    NULL Pointer is a pointer which is pointing to noting. In case, if we don't have address to be assigned to a pointer, then we can simply use NULL.

    ```c
    #include <stdio.h>
    
    int main(void)
    {
        // NULL Pointer
        int *ptr = NULL;
        printf("The value of ptr is %u\n", ptr);
        return 0;
    }
    ```

    - ***Important Points***

        - **NULL vs Unitialized Pointer**

            An unitialized pointer stores an undefined value. A null pointer stores a defined value, but one that is defined by the environment to not be a valid address for any member or object.

        - **NULL vs Void Pointer**

            NULL pointer is a value, while void pointer is a type.

- **Wild Pointer**

    A pointer which has not been initialized to anything (not even NULL) is known as wild pointer. The pointer may be initialized to a non-NULL garbage value that may not be a valid address.

    ```c
    void main(void)
    {
        int *p;     /* wild pointer */
        int x = 10;
        // p is not a wild pointer now
        p = &x;
    }
    ```    

* * *

### 6. References

1. [https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Pointers)

1. [http://www.geeksforgeeks.org/dangling-void-null-wild-pointers/](http://www.geeksforgeeks.org/dangling-void-null-wild-pointers/)

