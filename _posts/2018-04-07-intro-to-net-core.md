---
layout: post
title: Intro to .NET (Core)
date: 2018-04-07 17:10:15 +0800
categories: ['.NET']
tags: ['.NET']
disqus_identifier: 333887457919243711380116557278304717974
---
- TOC
{:toc}
- - -

## .NET

![.NET](/assets/intro-dot-net/dot-net-arch.png)

- .NET is a free, cross-platform, open source developer platform for building many different types of applications.
- With .NET, you can use multiple languages, editors, and libraries to build for web, mobile, desktop, gaming, and IoT.
- .NET Framework/.NET Core/Mono (Xamarin)
    - **C#**/VB.NET/F#
    - Assembly/DLL/MS**IL**
- Common Language Runtime (CLR)
    - GC/JIT
    - **CoreCLR**
- Base Class Library (BCL)
    - **CoreFX**
- Framework Class Library (FCL)
    - ASP.NET/Windows Forms/WPF
    - **ASP.NET Core**

### .NET Standard <small>specification</small>

- The .NET Standard is **a formal specification of .NET APIs that are intended to be available on all .NET implementations**. The motivation behind the .NET Standard is establishing greater uniformity in the **.NET ecosystem**.
- The .NET Standard enables the following key scenarios:
    - Defines uniform set of BCL APIs for all .NET implementations to implement, independent of workload.
    - Enables developers to produce **portable libraries** that are usable **across .NET implementations**, using this same set of APIs.
    - Reduces or even eliminates conditional compilation of shared source due to .NET APIs, only for OS APIs.

![.NET Standard](/assets/intro-dot-net/dot-net-standard-implementation-support.png)

### .NET Framework

- An implementation of .NET that **runs only on Windows**.

- Includes the Common Language Runtime (CLR), the Base Class Library, and application framework libraries such as ASP.NET, Windows Forms, and WPF.

### .NET Core

- A **cross-platform**, high-performance, open source implementation of .NET.
- Includes the Core Common Language Runtime (**CoreCLR**), the Core AOT Runtime (**CoreRT**, in development), the Core Base Class Library (**CoreFX**), and the **Core SDK**.
- .NET Core can be thought of as a cross-platform version of the .NET Framework, at the layer of the .NET Framework Base Class Libraries (BCL). It **implements the .NET Standard specification**. .NET Core provides a subset of the APIs that are available in the .NET Framework or Mono/Xamarin.
- **Flexible deployment**: Can be included in your app or installed side-by-side user- or machine-wide.
- **Cross-platform**: Runs on Windows, macOS and Linux; can be ported to other operating systems.
- **Command-line tools**: All product scenarios can be exercised at the command-line.
- **Compatible**: .NET Core is compatible with .NET Framework, Xamarin and Mono, via the .NET Standard.
- **Open source**: The .NET Core platform is open source, using MIT and Apache 2 licenses. Documentation is licensed under CC-BY. .NET Core is a .NET Foundation project.
- **Supported by Microsoft**: .NET Core is supported by Microsoft, per .NET Core Support

### Xamarin/Mono

- Mono is a .NET implementation that is mainly used when a **small runtime** is required.
- It is the runtime that powers **Xamarin** applications on **Android**, **Mac**, **iOS**, **tvOS** and **watchOS** and is focused primarily on apps that require a small footprint.
- Historically, Mono implemented the larger API of the .NET Framework and emulated some of the most popular capabilities on Unix.

## Deep into .NET Core

- .NET Core is a platform made of NuGet **packages**. Some product experiences benefit from fine-grained definition of packages while others from coarse-grained. To accommodate this duality, the product is distributed as a fine-grained set of packages and then described in coarser chunks with a package type informally called a "**metapackage**".
- Each of the .NET Core packages support being run on multiple .NET implementations, represented as **frameworks**. Some of those frameworks are traditional frameworks, like **net461**, representing the .NET Framework. Another set is new frameworks that can be thought of as "**package-based frameworks**", like **netcoreapp2.0**, which establish a new model for defining frameworks. These package-based frameworks are entirely formed and defined as packages, forming a strong relationship between packages and frameworks.

### Packages

- .NET Core is split into a set of packages, which provide primitives, higher-level data types, app composition types and common utilities. **Each of these packages represent a single assembly of the same name. **
- There are advantages to defining packages in a fine-grained manner:
    - Fine-grained packages can ship on their own schedule with relatively limited testing of other packages.
    - Fine-grained packages can provide differing OS and CPU support.
    - Fine-grained packages can have dependencies specific to only one library.
    - Apps are smaller because unreferenced packages don't become part of the app distribution.

### Metapackages

- Metapackages are a NuGet package convention for describing a set of packages that are meaningful together. They represent this set of packages by making them dependencies. They can optionally establish a framework for this set of packages by specifying a framework (**Package-based Frameworks**).
- **NETStandard.Library** - Describes the libraries that are part of the ".NET Standard". Applies to all .NET implementations (for example, .NET Framework, .NET Core and Mono) that support .NET Standard. Establishes the 'netstandard' framework.
-  **Microsoft.NETCore.App** - Describes the libraries that are part of the .NET Core distribution. Establishes the **.NETCoreApp** framework. 

### .NET Core SDK

- .NET Core Software Development Kit (SDK) is a set of libraries and tools that allow developers to create .NET Core applications and libraries. 
- It contains the following components:
    - The .NET Core Command Line Tools that are used to build applications
    - .NET Core (libraries and runtime) that allow applications to both be built and run
    - The **dotnet** driver for running the CLI commands as well as running applications

### .NET Core CLI

- The .NET Core command-line interface (CLI) is **a new cross-platform toolchain for developing .NET applications**.
- The CLI is a foundation upon which higher-level tools, such as Integrated Development Environments (IDEs), editors, and build orchestrators, can rest.
- Basic commands
    - restore/**build**/**publish**/**run**/test/**pack**/clean/help
- Project modification commands
    - add package/add reference/remove package/remove reference/list reference

## Target frameworks

- The collection of APIs that a .NET app or library relies on.
- An app or library can target **a version of .NET Standard** (for example, .NET Standard 2.0), which is specification for a standardized set of APIs across all .NET implementations.
- An app or library can also target **a version of a specific .NET implementation**, in which case it gets access to implementation-specific APIs. For example, an app that targets Xamarin.iOS gets access to Xamarin-provided iOS API wrappers.

### .NET Standard <small>framework</small>

- The .NET Standard (TFM: **netstandard**) framework represents the APIs defined by and built on top of the .NET Standard. Libraries that are intended to run on multiple runtimes should target this framework.
- They will be **supported on any .NET Standard compliant runtime**, such as .NET Core, .NET Framework and Mono/Xamarin. Each of these runtimes supports a set of .NET Standard versions, depending on which APIs they implement.
- The **netstandard framework** implicitly references the **NETStandard.Library** metapackage.

### .NET Core Application <small>framework</small>

- The .NET Core Application (TFM: **netcoreapp**) framework represents the packages and associated APIs that come with the .NET Core distribution and the **console application model** that it provides.
- **.NET Core apps must use this framework, due to targeting the console application model**, as should libraries that intended to run only on .NET Core. Using this framework restricts apps and libraries to running only on .NET Core. 

### .NET Framework

- The .NET Framework (TFM: **net**) represents the available APIs defined by the assemblies that a .NET implementation installs on Windows platform, which includes application framework APIs (for example, ASP.NET, WinForms and WPF). 

## Introduction to ASP.NET Core

- ASP.NET Core is a cross-platform, high-performance, open-source framework for building modern, cloud-based, Internet-connected applications.
- Startup / DI / Middleware / Routing / Hosting
- Model Binding / Controllers / Views / Filters
- Kestrel (libuv) / IIS (ANCM) / Nginx

```csharp
// An ASP.NET Core application is a console app that creates a web server in its Main method:
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;

namespace aspnetcoreapp
{
    public class Program
    {
        public static void Main(string[] args)
        {
            BuildWebHost(args).Run();
        }

        public static IWebHost BuildWebHost(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>()
                .Build();
    }
}
```

## References

1. What is .NET?, [https://www.microsoft.com/net/learn/what-is-dotnet](https://www.microsoft.com/net/learn/what-is-dotnet)
1. .NET Glossary, [https://docs.microsoft.com/en-us/dotnet/standard/glossary](https://docs.microsoft.com/en-us/dotnet/standard/glossary)
1. .NET architectural components, [https://docs.microsoft.com/en-us/dotnet/standard/components](https://docs.microsoft.com/en-us/dotnet/standard/components)
1. .NET Standard, [https://docs.microsoft.com/en-us/dotnet/standard/net-standard](https://docs.microsoft.com/en-us/dotnet/standard/net-standard)
1. Introduction to ASP.NET Core, [https://docs.microsoft.com/en-us/aspnet/core/](https://docs.microsoft.com/en-us/aspnet/core/)
1. [https://github.com/dotnet](https://github.com/dotnet)
