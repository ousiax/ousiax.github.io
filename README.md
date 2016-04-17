# [LESS IS MORE](http://qqbuby.github.io)

* * *

    #include <stdio.h>
    
    int main()
    {
        printf("Hello, 世界!\n");
        return 0;
    }


> $ cc hello.c && ./a.out 
> Hello, 世界!
    
* * *

    class Hello {
        public static void main(String[] args) {
            System.out.println("Hello, 世界!");
        }
    }
    
> $ javac hello.java && java Hello
> Hello, 世界!

* * *

    using System;
    
    class Program {
        static void Main() {
            Console.WriteLine("Hello, 世界!");
        }   
    }

> $ mono-csc hello.cs && mono hello.exe
> Hello, World!

* * *

    #!/usr/bin/env python
    # -*- coding: utf-8 -*-
    
    
    def main():
        print 'Hello, 世界!'
    
    if __name__ == '__main__':
        main()

> $ python hello.py 
> Hello, 世界!

* * *

    package main
    
    import (
        "fmt"
    )
    
    func main() {
        fmt.Printf('Hello, 世界!\n')
    }
    
> $ go run hello.go 
> Hello, 世界!

* * *

    #!/usr/bin/env ruby
    # -*- coding: utf-8 -*-
    
    def main()
      puts 'Hello, 世界!'
    end
    
    main()
    
> $ ruby hello.rb 
> Hello, 世界!