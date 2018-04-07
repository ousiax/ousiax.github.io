---
layout: post
title: "Cloudera ODBC Driver for Impala on Debian/Linux with .NET Core 2.0"
date: 2017-11-16 15:30:14 +0800
categories: ['ODBC']
tags: ['ODBC', '.NET', 'Linux', 'Kerberos', 'Impala']
disqus_identifier: 49461911245416724591536676219870654213
---

- TOC
{:toc}

- - -

### 1 What is ODBC?

Open Database Connectivity (ODBC) is a standard software API specification for using database management system (DBMS). ODBC is independent of programming language, database system and operating system.

ODBC was created by the SQL Access Group and first released in September, 1992. ODBC is based on the Call Level Interface (CLI) specifications from SQL, X/Open (now part of The Open Group), and the ISO/IEC.

The ODBC API is a library of ODBC functions that let ODBC-enabled applications connect to any database for which an ODBC driver is available, execute SQL statement, and retrieve results.

The goal of ODBC is to make it possible to access any data from any application, regardless of which database management system (DBMS) is handing the data. ODBC achieves this by inserting a middleware layer called a database driver between an application and the DBMS. This layer translates the application's data queries into commands that the DBMS understands.

### 1.1 Components of ODBC

A basic implementation of ODBC on Linux is comprised of:

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
$ odbcinst -j
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
$ odbcinst -q -s
[Cloudera ODBC Driver for Impala]
[MYSQL]
```

#### 2.4 How do you install an ODBC driver?

You can directly edit your odbcinst.ini or .odbcinst.ini file and add the driver definition.

```ini
[DRIVER_NAME]
Description = description of the ODBC driver
Driver      = path_to_odbc_driver_shared_object
Setup       = path_to_driver_setup_shared_object
```

In the *odbcinst.ini* each driver definition begins with the driver name in square brackets. The driver name is followed by Driver and Setup attributes where Driver is the path to the ODBC driver shared object (exporting the ODBC API) and Setup is the path to the ODBC driver setup library (exporting the ConfigDriver and ConfigDSN APIs used to install/remove the driver and create/edit/delete data sources).

The following is a sample for MySQL ODBC 5.3 Driver:

```ini
[MySQL ODBC 5.3 Driver]
Driver      = /usr/local/lib/libmyodbc5w.so
UsageCount  = 1
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
$ odbcinst -q -d
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
$ sudo dpkg -i ClouderaImpalaODBC-32bit-Version-Release_i386.deb # or ClouderaImpalaODBC-Version-Release_amd64.deb.
```

The Cloudera ODBC Driver for Impala files are installed in the */opt/cloudera/impalaodbc* directory.

You can also verify the driver version number on Linux like:

```sh
$ dpkg -l | grep cloudera
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
Restore succeeded.

$ tree clouderaimpalaodbc/
clouderaimpalaodbc/
|-- Program.cs
|-- clouderaimpalaodbc.csproj
`-- nuget.config

0 directories, 3 files

```

```sh
$ dotnet add package System.Data.Odbc -v 4.5.0-preview1-25914-04
```

*clouderaimpalaodbc.csproj*

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>netcoreapp2.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="System.Data.Odbc" Version="4.5.0-preview1-25914-04" />
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

```sh
$ dotnet run
2333
```

#### 3.3 MIT Kerberos

Kerberos must be installed and configured before you can use this authentication mechanism. For more information, refer to the MIT Kerberos Documentation: [http://web.mit.edu/kerberos/krb5-latest/doc/](http://web.mit.edu/kerberos/krb5-latest/doc/).


```sh
$ # Install the krb5 user utils
$ apt-cache search krb5-user
krb5-user - basic programs to authenticate using MIT Kerberos
$sudo apt-get install krb5-user -y
```

```sh
$ # Get Kerberos ticket with `kinit`
$ kinit username
Password for username@CLOUDERA.COM:
$ klist
Ticket cache: FILE:/tmp/krb5cc_0
Default username: username@CLOUDERA.COM

Valid starting     Expires            Service username
02/02/18 10:39:13  02/02/18 20:39:13  krbtgt/CLOUDERA.COM@CLOUDERA.COM
        renew until 02/09/18 10:37:57
$ kdestroy
$ klist
klist: No credentials cache found (filename: /tmp/krb5cc_0)
```

```sh
$ # Create a keytab file
$ ktutil
ktutil:  addent -password -p username@ADS.IU.EDU -k 1 -e rc4-hmac
Password for username@ADS.IU.EDU: [enter your password]
ktutil:  addent -password -p username@ADS.IU.EDU -k 1 -e aes256-cts
Password for username@ADS.IU.EDU: [enter your password]
ktutil:  wkt username.keytab
ktutil:  quit
```

```sh
$ # List the keys in a keytab file
$ klist -k mykeytab
version_number username@ADS.IU.EDU
version_number username@ADS.IU.EDU
```

```sh
$ # Merge keytab files
$ ktutil
ktutil: read_kt mykeytab-1
ktutil: read_kt mykeytab-2
ktutil: read_kt mykeytab-3
ktutil: write_kt krb5.keytab
ktutil: quit
$ # To verify the merge:
$ klist -k krb5.keytab
```

> The keytab file is independent of the computer it's created on, its filename, and its location in the file system. Once it's created, you can rename it, move it to another location on the same computer, or move it to another Kerberos computer, and it will still function. The keytab file is a binary file, so be sure to transfer it in a way that does not corrupt it.
> 
> If possible, use *SCP* or another secure method to transfer the keytab between computers. 

#### 3.4 Using Advanced Kerberos Authentication

This authentication mechanism allows concurrent connections within the same process to use different Kerberos user principals.

When you use Advanced Kerberos authentication, you do not need to run the `kinit` comamnd to obtain a Kerberos ticket. Instead, you use a JSON file to map your Impala user name to a Kerberos user principal name and a keytab that contains the corresponding keys. The driver obtains Kerberos tickets based on the specified mapping. As a fallback, you can specify a keytab that the driver uses by default if the mapping file is not available or if no matching keytab can be found in the mapping file.

- **AuthMech**

    The authentication mechanism to use.

    Select one of the following settings, or set the key to the corresponding number:
    - No Authentication (`0`)
    - Kerberos (`1`)
    - SASL User Name (`2`)
    - User Name And Password (`3`)

- **UPNKeytabMappingFile**

    The full path to a JSON file that maps your Impala user name to a Kerberos user principal name and a ketab file.
    
    > Note: This option is applicable only when the authentication mechanism is set to Kerberos (`AuthMech=1`) and the Use Keytab option is enabled (`UseKeytab=1`).
    
    The mapping in the JSON file must be written using the following schema, where *[UserName]* is the Impala user name, *[KerberosUPN]* is the Kerberos user principal name, and *[KeytabFile]* is the full path to the keytab file:
    
    ```json
    {
      "[UserName]": {
        "principal" : "[KerberosUPN]",
        "keytabfile": "[KeytabFile]"
      },
      ...
    }
    ```
    
    For example, the following file maps the Impala user name **cloudera** to the **cloudera@CLOUDERA** Kerberos user principal name and the `C:\Temp\cloudera.keytab` file:
    
    ```json
    {
      "cloudera": {
        "principal" : "cloudera@CLOUDERA",
        "keytabfile": "C:\Temp\cloudera.keytab"
      },
      ...
    }
    ```
    
    If parts of the mapping are invalid or not defined, then the following occurs:
    - If the mapping file fails to specify a Kerberos user principal name, then the driver uses the Impala user name as the Kerberos user pricipal name.
    - If the mapping file fails to specify a keytabl file, then the driver uses the keytab file that is specified in the Default Keytab File setting.
    - If the entire mapping file is invalid or not defined, then the driver does both of the actions described above.

- **UseKeytab**

    The option specifies whether the driver obtains the ticket for Kerberos authentication by using a keytab:
    - Enable (`1`): The driver uses a keytab to obtain a ticket before authenticating the connection using Kerberos.
    - Disable (`0`): The driver does not attempt to obtains the Kerberos ticket, and assumes that a valid ticket is already available in the credentials cache.
    
    > Note: This option is applicable only when the authentication mechanism is set to Kerberos (`AuthMech=1`).
    
    If you enable this option but do not set the Default Keytab File option (the `DefaultKeytabFile` key), then the MIT Kerberos library will search for a keytab file using the following search order:
    - The file specified by the `KRB5_KTNAME` environment variable.
    - The `default_keytabl_name` settings in the `[libdefaults]` section of the Kerberos confirugration file (`krb5.conf`/`krb5.ini`).
    - The default keytab file specified in the MIT Kerberos library. Typically, the default file is `C:\Windows\krb5kt` for Windows platforms and `/etc/krb5.keytab` for non-Windows platforms.

- **DefaultKeytabFile**

    The full path to the keytab file that the driver uses to obtain the ticket for Keberos authentication.
    > This option is applicable only when the authentication mechanism is set to Kerberos (`AuthMech=1`) and the Use Keytab option is enabled (`UseKeytab=1`).
    > If the UPN Keytab Mapping File option (the `UNPNKeytabMappingFile` key) is set to a JSON file with a valid mapping to a keytab, then that keytab takes prcedence.

    If you do not set this option but the Use Keytab option is enabled (`UseKeytab=1`), then the MIT Kerberos library will search for a keytab using the following search order.
    - The file specified by the `KRB5_KTNAME` environment variable.
    - The `default_keytabl_name` settings in the `[libdefaults]` section of the Kerberos confirugration file (`krb5.conf`/`krb5.ini`).
    - The default keytab file specified in the MIT Kerberos library. Typically, the default file is `C:\Windows\krb5kt` for Windows platforms and `/etc/krb5.keytab` for non-Windows platforms.

**To configure Kerberos authentication**

1. Set the `AuthMech` connection attribute to 1.
2. Choose one:
    - To use the default realm defined in your Kerberos setup, do not set the `KrbRealm` attribute.
    - Or, if your Kerberos setup does not define a default realm or if the realm of your Impala server is not the default, then set the appropriate realm using the `KrbRealm` attribute.
3. Set the `KrbFQDN` attribute to the fully qualified domain name of the Impala server host.
    > To use the Impala server host name as the fully qualified domain name for Kerberos authentication, set `KrbFQDN` to `_HOST`.
4. Set the `KrbServiceName` attribute to the service name of the Impala server.
5. Optionally, set the `TSaslTransportBufSize` attribute to the number of bytes to reserve in memory for buffering unencrypted data from the network.
    > In most circumstances, the default value of 1000 bytes is optimal.

**To configure Advanced Kerberos authentication:**

1. Set the `AuthMech` connection attribute to `1`.
1. Choose one:
    - To use the default realm defined in your Kerberos setup (`krb5.conf`/`krb5.ini`), dot not set the `KrbRealm` attribute.
    - Or, if your Kerberos setup does not define a default realm or if the realm of your Impala server is not the default, then set the appropriate realm using the `KrbRealm` attribute.
1. Optionally, if you are using MIT Kerberos and a Kerberos realm is specified using the `KrbRealm` connection attribute, the choose one: 
    - To have the Kerberos layer cannoicalize the server's service principal name, leave the `ServicePrincipalCanonicalization` attribute set to `1`.
    - Or, to prevent the Kerberos layer from canonicalizing the server's service principal name, set the `ServicePrincipalCanonicalization` attribute to `0`.
1. Set the `KrbFQDN` attribute to the fully qualified domain name of the Impala server host.
> Note: To use the Impala server host name as the fully qualified domain name for Kerberos authentication, set `KrbFQDN` to `_HOST`.
1. Set the `KrbServiceName` attribute to the service name of the Impala server.
1. Set the `UseKeytab` attribute to `1`.
1. Set the `UID` attribute to an appropriate user name for accessing the Impala server.
1. Set the `UPNKeytabMappingFile` attribute to the full path to a JSON file that maps your Impala user name to a Kerberos user principal name and a keytab file.
1. Set the `DefaultKeytabFile` attribute to the full path to a keytab file that the driver can use if the mapping file is not available or if no matching keytab can be found in the mapping
file.
1. If the Impala server is configured to use SSL, then configure SSL for the connection. 
1. Optionally, set the `TSaslTransportBufSize` attribute to the number of bytes to reserve in memory for buffering unencrypted data from the network.
> Note: In most circumstances, the default value of 1000 bytes is optimal.

The following is the format of a DSN-less connection string that connects to an Impala server using Advanced Kerberos authentication:

```
Driver=Cloudera ODBC Driver for Impala;
Host=[Server];
Port=[PortNumber];
AuthMech=1;
KrbRealm=[Realm];
KrbFQDN=[DomainName];
KrbServiceName=[ServiceName];
UseKeytab=1;
UID=[YourUserName];
UPNKeytabMappingFile=[MappingFile];
```

For example:

```
Driver=Cloudera ODBC Driver for Impala;
Host=192.168.222.160;
Port=21050;
AuthMech=1;
KrbRealm=CLOUDERA;
KrbFQDN=localhost.localdomain;
KrbServiceName=impala;
UseKeytab=1;
UID=cloudera;
UPNKeytabMappingFile=C:\Temp\cloudera.keytab;
```

If you are connecting to the server through SSL, then set the `SSL` property to `1`. For example:

```
Driver=Cloudera ODBC Driver for Impala;
Host=192.168.222.160;
Port=21050;
AuthMech=1;
KrbRealm=CLOUDERA;
KrbFQDN=localhost.localdomain;
KrbServiceName=impala;
UseKeytab=1;
UID=cloudera;
UPNKeytabMappingFile=C:\Temp\cloudera.keytab;
SSL=1;
```
- - -

### References

1. Linux/UNIX ODBC, [https://www.easysoft.com/developer/interfaces/odbc/linux.html](https://www.easysoft.com/developer/interfaces/odbc/linux.html)
1. Download Impala ODBC Connector 2.5.40, [https://www.cloudera.com/downloads/connectors/impala/odbc/2-5-40.html](https://www.cloudera.com/downloads/connectors/impala/odbc/2-5-40.html)
1. Cloudera ODBC 2.5.40 Driver Documentation for Impala, [https://www.cloudera.com/documentation/other/connectors/impala-odbc/latest.html](https://www.cloudera.com/documentation/other/connectors/impala-odbc/latest.html)
1. Unhandled Exception: System.Data.Odbc.OdbcException: ERROR \[H\] \[unixODBC\]\[ |  UNICODE Using encoding ASCII 'ANSI\_X3.4-1968' and UNICODE 'UCS-2LE', [https://github.com/dotnet/corefx/issues/25269](https://github.com/dotnet/corefx/issues/25269)
1. Successfully configuring an ODBC driver to access Redshift from SAS on Linux, [https://communities.sas.com/t5/SAS-Communities-Library/Successfully-configuring-an-ODBC-driver-to-access-Redshift-from/ta-p/223987](https://communities.sas.com/t5/SAS-Communities-Library/Successfully-configuring-an-ODBC-driver-to-access-Redshift-from/ta-p/223987)
1. Use a keytab, [https://kb.iu.edu/d/aumh](https://kb.iu.edu/d/aumh)
1. linux - Kerberos ktutil, what kinds of encryption are available? - Server Fault, [https://serverfault.com/questions/620521/kerberos-ktutil-what-kinds-of-encryption-are-available](https://serverfault.com/questions/620521/kerberos-ktutil-what-kinds-of-encryption-are-available)
1. Environment variables — MIT Kerberos Documentation, [https://web.mit.edu/kerberos/krb5-devel/doc/admin/env_variables.html](https://web.mit.edu/kerberos/krb5-devel/doc/admin/env_variables.html)
