---
layout: post
title: "Introducing .NET Core"
date: 2016-04-21 18:42:47 +0800
categories: ['.NET']
tags: ['.NET']
disqus_identifier: 35811435433344702174377364430072930216
---
#### .NET Core

.NET Core is a modular, streamlined subset of the .NET Framework and CLR. It is fully open-source and provides a common set of libraries that can be targeted across numerous platforms. Its factored approach allows applicattions to take depedencies only on those portions of the CoreFX that they use, and the smaller runtime is ideal for deployment to both small devices as well as cloud-optimized environments that need to be able to run many small applications side-by-side.

.NET Core consists of a set of libraries, called "[CoreFX](https://github.com/dotnet/coreFX)", and a small, optimized runtime, called "[CoreCLR](https://github.com/dotnet/coreCLR)".

The CoreCLR runtime (Microsoft.CoreCLR) and CoreFX libraries are distributed via NuGet. The CoreFX libraries are factored as individual NuGet packages according to funcitonality, named "System.[module]" on [nuget.org](https://nuget.org).

.NET Core can be used to build a variety of applicaitons using different application models including Web applications, console applications and native mobile applications. The .NET Execution Environment (DNX) provides a cross-platform runtime host that you can use to build .NET Core based applications that run on Windows, Mac and Linux and is the foudation for running ASP.NET application on .NET Core. Applications running on DNX can target the .NET Framework or .NET Core.

*project.json*

    "frameworks": {
        "dnx451": {},
        "dnxcore50": {}
    }

`dnx451` represents the .NET Framework, while `dnxcore50` represents .NET Core 5 (5.0). You can use compiler directives (`#if`) to check for symbols that correspond to the two frameworks: `DNX451` and `DNXCORE50`.

#### ASP.NET 5

ASP.NET is a significant redesign of ASP.NET. ASP.NET is a new open-source and cross-platform framework for building modern cloud-based Web applications using .NET. You can develop and run your ASP.NET 5 applications cross-platform on Windows, Mac and Linux.

ASP.NET 5 is built with the needs of modern Web applications in mind, including a unified story for building Web UI and Web APIs that integrate with today's modern's modern client-side frameworks and development workflows. ASP.NET is also built to be cloud-ready by introducing environment-based configuration and by providing built-in dependency injection support.


* New light-weight and modular HTTP request pipeline
* Ability to host on IIS or self-host in your own process
* Built on .NET Core, which supports true side-by-side app versioning
* Ships entirely as NuGet packages
* Integrated support for creating and using NuGet packages
* Single aligned web stack for Web UI and Web APIs
* Cloud-ready environment-based configuration
* Built-in support for dependency injection
* New tooling that simplifies modern web development
* Build and run cross-platform ASP.NET apps on Windows, Mac and Linux
* Open source and community focused

ASP.NET applications are built and run using the .NET Execution Environment (DNX). Every ASP.NET 5 project is a DNX project. ASP.NET 5 integrates with DNX through the [ASP.NET Application Hosting](https://nuget.org/packages/Microsoft.AspNet.Hosting) package.

ASP.NET 5 applications are defined using a public `Startup` class:

    public class Startup
    {
        public void ConfigureServices(IServiceCollection services)
        {
        }

        public void Configure(IApplicationBuilder app)
        {
        }

        public static void Main(string[] args => WebApplication.Run<Startup>(args);
    }

#### .NET Execution Environment (DNX)

The .NET Execuation Environment (DNX) is a software development kit (SDK) and runtime environment that has everything you need to build and run .NET application for Windows, Mac and Linux. It provides a host process, CLR hosting logic and managed entry point discovery.

**Cross-platform .NET development** DNX provides a consistent development and execution environment across multiple platforms (Windows, Mac and Linux) and across different .NET flavors (.NET Framework, .NET Core and Mono). With DNX you can development your application on one platform and run it on a different platform as long as you have a compatilbe DNX installed on that platform.

*To install DNX for .NET Core (Debian):*

1. Install the DNX prerequisites

        sudo apt-get install libunwind8 gettext libssl-dev libcurl4-openssl-dev zlib1g libicu-dev uuid-dev

2. User DNVM to install DNX for .NET Core:

        dnvm upgrade -r coreclr

Use this snippet to install the lastest stable DNX (.NET Excution Environment).

    dnvm install latest

#### .NET Version Manger (DNVM)

You can install multiple DNX versions and flavors on your machine. To install and manage different DNX versions and flavors you use the .NET Version Manger (DNVM). DNVM lets you list the different DNX versions and flavors on your matchine, install new ones and switch the active DNX.

To install DNVM on *Windows* open a command prompt and run the following

    @powershell -NoProfile -ExecutionPolicy unrestricted -Command "&{iex ((new-object net.webclient).DownloadString('https://dist.asp.net/dnvm/dnvminstall.ps1'))}"

To install DNVM on *Linux or OS X* open a terminal and run the following

    curl -sSL https://dist.asp.net/dnvm/dnvminstall.sh | sh && source ~/.dnx/dnvm/dnvm.sh

* * *

#### References

* [Introducing .NET Core](https://docs.asp.net/en/latest/conceptual-overview/dotnetcore.html)
* [Introduction to ASP.NET 5](https://docs.asp.net/en/latest/conceptual-overview/aspnet.html)
* [DNX Overview](https://docs.asp.net/en/latest/dnx/overview.html)
* [Installing ASP.NET 5 On Linux](https://docs.asp.net/en/latest/getting-started/installing-on-linux.html)
