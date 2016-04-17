# [LESS IS MORE](http://qqbuby.github.io)

* * *
```c
#include <stdio.h>

int main()
{
    printf("Hello, 世界!\n");
    return 0;
}
```

```bash
$ cc hello.c && ./a.out 
Hello, 世界!
```
    
* * *

```java
class Hello {
    public static void main(String[] args) {
        System.out.println("Hello, 世界!");
    }
}
```

```bash
$ javac hello.java && java Hello
Hello, 世界!
```

* * *

```csharp
using System;

class Program {
    static void Main() {
        Console.WriteLine("Hello, 世界!");
    }   
}
```

```bash
$ mono-csc hello.cs && mono hello.exe
Hello, 世界!
```

* * *

```py
#!/usr/bin/env python
# -*- coding: utf-8 -*-


def main():
   print 'Hello, 世界!'

if __name__ == '__main__':
   main()
```

```bash
$ python hello.py 
Hello, 世界!
```

* * *

```go
package main

import (
    "fmt"
)

func main() {
    fmt.Printf('Hello, 世界!\n')
}
```
```bash
$ go run hello.go
Hello, 世界!
```

* * *

```ruby
    #!/usr/bin/env ruby
    # -*- coding: utf-8 -*-
    
    def main()
      puts 'Hello, 世界!'
    end
    
    main()
```

```bash
$ ruby hello.rb 
Hello, 世界!
```
