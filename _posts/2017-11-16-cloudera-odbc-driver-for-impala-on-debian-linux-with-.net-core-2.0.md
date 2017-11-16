---
layout: post
title: "Cloudera ODBC Driver for Impala on Debian/Linux with .NET Core 2.0"
date: 2017-11-16 15-30-14 +0800
categories: ['ODBC']
tags: ['ODBC', '.NET Core', 'Linux']
disqus_identifier: 49461911245416724591536676219870654213
---

- TOC
{:toc}

- - -

### 1 What is ODBC?

Open Database Connectivity (ODBC) is a standard software API specification for using database management system (DBMS). ODBC is independent of programming language, database system and operating system.

ODBC was created by the SQL Access Group and first released in September, 1992. ODBC is based on the Call Level Interface (CLI) specifications from SQL, X/Open (now part of The Open Group), and the ISO/IEC.

The ODBC API is a library of ODBC functions that let ODBC-enabled applications connect to any database for which an ODBC driver is available, execute SQL statement, and retrieve results.

The goal of ODBC is to make it possible to access any data from any application, regardless of which database management system (DBMS) is handing the data. ODBC achieves this by inserting a middleware layer called a database driver between an application an application and the DBMS. This layer translates the application's data queries into commands that the DBMS understands.

### 1.1 Components of ODBC

A basic implementation of ODBC on Linux is comprised fo:

- An ODBC compliant application i.e. an application which uses the ODBC API to talk to a DBMS.
- The ODBC Driver Manager. The ODBC Driver Mangaer is the link between an ODBC application and an ODBC driver.

    Applications requiring ODBC access link with the driver manager and make ODBC API calls which cause the driver manager to load the appropriate ODBC Driver.

- A repository containing a list of installed ODBC drivers and defined ODBC data sources. The ODBC driver manager normally looks after these definitions and consults them when applications connect to a data source.

- An ODBC driver. The ODBC driver translates ODBC API calls into something the backend DBMS understands. 

### 1.1 ODBC Driver Managers

There are two open source ODBC driver managers for UNIX ([unixODBC](http://www.unixodbc.org/) and [iODBC](http://www.iodbc.org/)). This document describes the unixODBC Driver Manger as it is the one included with most (if not all) Linux distributions and some UNIX distributions.

#### 1.2.1 What does the ODBC driver manager do?

The ODBC driver manager is the interface between an ODBC application and the ODBC driver.

- The driver manager principally provides the ODBC API so ODBC applications may link with a single shared object and be able to talk to a range of ODBC drivers. e.g. an application on Linux links with libodbc.so (the main driver manager shared object) without having to know at link time which ODBC driver it is going to be using.
- At run time the application provides a connection string which defines the ODBC data source it wants to connect to and this in turn defines the ODBC driver which will handle this data source. The driver manager loads the requested ODBC driver (with `dlopen(3)`) and passes all ODBC API calls on to the driver.
- In this way, an ODBC application can be built and distributed without knowing which ODBC driver it will be using.

However, this is a rather simplistic description of what the driver manger does. The ODBC driver manger also:

- Controls a repository of installed ODBC drivers (on Linux is the file *odbcinst.ini*).
- Controls a repository of defined ODBC data sources (on Linux these are the files *odbc.ini* and *.odbc.ini*).
- Provides the ODBC driver APIs (SQLGetPrivateProfileString and SQLWriteProfileString) to read and write ODBC data source attributes.
- Handles ConfigDSN which the driver exports to configure data sources.
- Provides APIs to install and uninstall driver (SQLInstallDriver).
- Maps ODBC version e.g. so an ODBC 2.0 application can work with an ODBC 3.0 driver and vice versa.
- Maps ODBC states between different versions of ODBC.
- Provides a cursor library for drivers which only support forwared-only cursors.
- Provides SQLDataSources and SQLDrivers so an application can find out which ODBC drivers are installed and what ODBC data sources are defined.
- Provides an ODBC administrator which drivers can use to install ODBC drivers and users can use to define ODBC data sources.

### 2 The unixODBC ODBC Driver Manager

#### 2.1 What is unixODBC?

unixODBC is a project created to provide ODBC on non-Windows platforms. It includes:

- An ODBC driver manger which adheres to the ODBC specification and replicates all the functionality you may be used to in the MS Windwos ODBC Driver Manger.
- A collection of open source ODBC drivers.
- A number of ODBC applications that illustrate ODBC usage and provide useful functionality e.g. the GUI DataManager, odbctest and isql/iusql.

#### 2.2 Where are ODBC drivers defined?

In unixODBC ODBC drivers are defined in the *odbcinst.ini* file. The location of this file is configure-time variable defined with `--sysconfdir` but it is always the file odbcinst.ini in the `--sysconfdir` defined path. If unixODBC is already installed you can use unixODBC's odbcinst program to locate the odbcinst.ini file used to defined driver:

```sh
# odbcinst -j
unixODBC 2.3.4
DRIVERS............: /etc/odbcinst.ini
SYSTEM DATA SOURCES: /etc/odbc.ini
FILE DATA SOURCES..: /etc/ODBCDataSources
USER DATA SOURCES..: /root/.odbc.ini
SQLULEN Size.......: 8
SQLLEN Size........: 8
SQLSETPOSIROW Size.: 8
```

You can tell unixODBC to look in a different path (to that wich it was configured) for the *odbcinst.ini* file and SYSTEM DSN file (*odbc.ini*) by defining and exporting the **ODBCSYSINI** environemnt varible. You can tell unixODBC to look in a different file for driver definitions (*odbcinst.ini*, by default) by defining and exporting the **ODBCINSTINI** environment variable.

#### 2.3 How do you create an ODBC data source

You can edit the SYSTEM or USER DSN ini file ( *odbc.ini* or *.odbc.ini*) and add a data source using the syntax:

```ini
[ODBC_datasource_name}
Driver = driver_name
Description = description_of_data_source
attribute1 = value
.
.
attributen = value
```

where, ODBC\_datasource\_name is the name you want to assign to this data source, Driver is assigned the path of the driver shared object or the name of the driver (see odbcinst.ini file for installed drivers and "attributen = value" is the name of an attribute and its value that the ODBC driver needs. e.g. for the *MySQL ODBC 5.3 Driver* you might define

```ini
[ODBC Data Sources]
MYSQL=MySQL ODBC 5.3 Driver

[MYSQL]
Driver      = MySQL ODBC 5.3 Driver
# Driver    = /usr/local/lib/libmyodbc5w.so
SERVER      = locahost
PORT        = 3306
USER        = root
Password    =
Database    =
```

You can list user and system datasources with:

```sh
# odbcinst -q -s
[Cloudera ODBC Driver for Impala]
[MYSQL]
```

#### 2.4 How do you install an ODBC driver?

You can directly edit your odbcinst.ini or .odbcinst.ini file and add the driver definition.

```ini
[MySQL ODBC 5.3 Driver]
Driver=/usr/local/lib/libmyodbc5w.so
UsageCount=1
```

#### 2.5 What does a data source look like?

Generally speaking a DSN is comprised of a name and a list of attribute/value pairs. Usually these attributes are passed to the ODBC API SQLDriverConnect as a semicolon string such as:

```
DSN=mydsn;attribute1=value;attribute2=value;attributen=value;
```

What a specific ODBC driver needs is dependent on that ODBC driver. Each ODBC driver should support a number of ODBC connection attributes which are passed to the ODBC API SQLDriverConenct. Any attributes are not defined in the ODBC connection string may be looked in any DSN defined in the ODBC connection string.

#### 2.6 Testing DSN connections

Once you have installed your ODBC driver and defined an ODBC data source you can test connection to it via unixODBC's isql/iusql utility. The format of isql/iusql's command line for testing connection is:

```sh
isql -v DSN_NAME db_username db_password
```

You should use the `-v` optoin because this casue isql to output any ODBC diagnostics if the connection fails.

#### 2.7 Tracing ODBC calls

The unixODBC driver manager can write a trace of all ODBC calls made to a file. This can be a very useful debugging aid but it should be remembered that tracing will slow you application down.

You can add a section to your *odbcinst.ini* file to enable tracing like:

```ini
[ODBC]
TraceFile = /tmp/sql.log
Trace = Yes
```
In the *odbcinst.ini* each driver definition begins with the driver name in squre brackets. The driver name is followed by Driver and Setup attributes where Driver is the path to the ODBC driver shared object (exporting the ODBC API) and Setup is the path to the ODBC driver setup library (exporting the ConfigDriver and ConfigDSN APIs used to install/remove and create/edit/delete data sources). Few ODBC drivers for UNIX have a setup dialogue.

You can list all installed ODBC drivers with:

```sh
# odbcinst -q -d
[MySQL ODBC 5.3 Driver]
[Cloudera ODBC Driver for Impala]
```

### 3 Cloudera ODBC Driver for Impala with .NET Core 2.0

#### 3.1 Installing the Driver on Debian

On 64-bit editions of Debian, you can execute both 32-bit and 64-bit application. However, 64-bit applications must use 64-bit drivers, and 32-bit applications must use 32-bit drivers. Make sure that you use the version of the driver that matches the bitness of the client application:

- ClouderaImpalaODBC-32bit-*[Version]*-*[Release]*_i386.deb for the 32-bit driver
- ClouderaImpalaODBC-*[Version]*-*[Release]*_amd64.deb for the 64-bit driver

*[Version]* is the version number of the driver, and *[Release]* is the release number for this version of the driver.

You can install both versions of the driver on the same machine.

To install the Cloudera ODBC Driver for Impala on Debian:

```sh
# dpkg -i ClouderaImpalaODBC-32bit-Version-Release_i386.deb # or ClouderaImpalaODBC-Version-Release_amd64.deb.
```

The Cloudera ODBC Driver for Impala files are installed in the */opt/cloudera/impalaodbc* directory.

You can also verify the driver version number on Linux like:

```sh
# dpkg -l | grep cloudera
ii  clouderaimpalaodbc          2.5.40.1025-2                  all          Cloudera ODBC Driver for Impala
```

Configure the ODBC Driver for Impala into the *.odbcinst.ini/odbcinst.ini* as blow:

```ini
[Cloudera ODBC Driver for Impala]
Description=Cloudera ODBC Driver for Impala
Driver=/opt/cloudera/impalaodbc/lib/64/libclouderaimpalaodbc64.so
```

#### 3.2 Create a .NET Core Console Application 

```sh
$ dotnet new console -o clouderaimpalaodbc
The template "Console Application" was created successfully.
.
.
.
Restore succeeded.

$ dotnet new nugetconfig

$ tree clouderaimpalaodbc/
clouderaimpalaodbc/
|-- Program.cs
|-- clouderaimpalaodbc.csproj
`-- nuget.config

0 directories, 3 files

```

*nuget.config*

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <clear />
  <packageSources>
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
    <add key="dotnet.myget.org/F/dotnet-core" value="https://dotnet.myget.org/F/dotnet-core/api/v3/index.json" />
  </packageSources>
</configuration>
```

```sh
$ dotnet add package System.Data.Odbc -v 4.5.0-preview1-25915-02
```

*clouderaimpalaodbc.csproj*

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>netcoreapp2.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="System.Data.Odbc" Version="4.5.0-preview1-25915-02" />
  </ItemGroup>
</Project>
```

*Program.cs*

```cs
using System;
using System.Data.Odbc;

namespace clouderaimpalaodbc
{
    class Program
    {
        static void Main(string[] args)
        {
            // replace the HOST and Port with your Cloudera Impala Cluster Node.
            using (var conn = new OdbcConnection("Driver=Cloudera ODBC Driver for Impala;Host=10.10.10.10;Port=21050;"))
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT COUNT(*) FROM mydatabase.session WHERE profile_id=2160 AND day=20171115";
                    Console.WriteLine(cmd.ExecuteScalar());
                }
            }
        }
    }
}
```

- - -

### References

1. Linux/UNIX ODBC, [https://www.easysoft.com/developer/interfaces/odbc/linux.html](https://www.easysoft.com/developer/interfaces/odbc/linux.html)
1. Download Impala ODBC Connector 2.5.40, [https://www.cloudera.com/downloads/connectors/impala/odbc/2-5-40.html](https://www.cloudera.com/downloads/connectors/impala/odbc/2-5-40.html)
1. Cloudera ODBC 2.5.40 Driver Documentation for Impala, [https://www.cloudera.com/documentation/other/connectors/impala-odbc/latest.html](https://www.cloudera.com/documentation/other/connectors/impala-odbc/latest.html)
1. Unhandled Exception: System.Data.Odbc.OdbcException: ERROR \[H\] \[unixODBC\]\[ |  UNICODE Using encoding ASCII 'ANSI\_X3.4-1968' and UNICODE 'UCS-2LE', [https://github.com/dotnet/corefx/issues/25269](https://github.com/dotnet/corefx/issues/25269)
