---
layout: post
title: Greenplum 运维札记
date: 2020-11-18 16:07:04 +0800
categories: ['database']
tags: ['greenplum']
maifont: WenQuanYi Micro Hei
---

- TOC
{:toc}

---

### 1. 模拟环境信息

- Master: mdw
- Standby Master: smdw
- Segment Host: [smdw, sdw1]

```console
[gpadmin@mdw ~]$ gpstate -s
20201118:16:08:08:003865 gpstate:mdw:gpadmin-[INFO]:-Starting gpstate with args: -s
20201118:16:08:08:003865 gpstate:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
20201118:16:08:08:003865 gpstate:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58'
20201118:16:08:08:003865 gpstate:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20201118:16:08:08:003865 gpstate:mdw:gpadmin-[INFO]:-Gathering data from segments...
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:--Master Configuration & Status
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Master host                    = mdw
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Master postgres process ID     = 2697
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Master data directory          = /data/master/gpseg-1
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Master port                    = 5432
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Master current role            = dispatch
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Greenplum initsystem version   = 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Greenplum current version      = PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Postgres version               = 9.4.24
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Master standby                 = smdw
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Standby master state           = Standby host passive
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-Segment Instance Status Report
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Segment Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Hostname                          = sdw1
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Address                           = sdw1
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Datadir                           = /data/primary/gpseg0
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Port                              = 6000
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Mirroring Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Current role                      = Primary
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Preferred role                    = Primary
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Mirror status                     = Synchronized
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Status
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      PID                               = 3889
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Configuration reports status as   = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Database status                   = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Segment Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Hostname                          = smdw
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Address                           = smdw
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Datadir                           = /data/mirror/gpseg0
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Port                              = 7000
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Mirroring Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Current role                      = Mirror
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Preferred role                    = Mirror
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Mirror status                     = Streaming
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Replication Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      WAL Sent Location                 = 0/C093C48
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      WAL Flush Location                = 0/C093C48
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      WAL Replay Location               = 0/C093C48
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Status
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      PID                               = 6398
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Configuration reports status as   = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Segment status                    = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Segment Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Hostname                          = sdw1
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Address                           = sdw1
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Datadir                           = /data/primary/gpseg1
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Port                              = 6001
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Mirroring Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Current role                      = Primary
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Preferred role                    = Primary
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Mirror status                     = Synchronized
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Status
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      PID                               = 3888
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Configuration reports status as   = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Database status                   = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Segment Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Hostname                          = smdw
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Address                           = smdw
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Datadir                           = /data/mirror/gpseg1
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Port                              = 7001
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Mirroring Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Current role                      = Mirror
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Preferred role                    = Mirror
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Mirror status                     = Streaming
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Replication Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      WAL Sent Location                 = 0/C093C48
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      WAL Flush Location                = 0/C093C48
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      WAL Replay Location               = 0/C093C48
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Status
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      PID                               = 6397
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Configuration reports status as   = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Segment status                    = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Segment Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Hostname                          = smdw
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Address                           = smdw
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Datadir                           = /data/primary/gpseg2
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Port                              = 6000
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Mirroring Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Current role                      = Primary
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Preferred role                    = Primary
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Mirror status                     = Synchronized
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Status
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      PID                               = 4038
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Configuration reports status as   = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Database status                   = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Segment Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Hostname                          = sdw1
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Address                           = sdw1
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Datadir                           = /data/mirror/gpseg2
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Port                              = 7000
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Mirroring Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Current role                      = Mirror
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Preferred role                    = Mirror
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Mirror status                     = Streaming
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Replication Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      WAL Sent Location                 = 0/C040B10
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      WAL Flush Location                = 0/C040B10
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      WAL Replay Location               = 0/C040B10
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Status
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      PID                               = 3891
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Configuration reports status as   = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Segment status                    = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Segment Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Hostname                          = smdw
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Address                           = smdw
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Datadir                           = /data/primary/gpseg3
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Port                              = 6001
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Mirroring Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Current role                      = Primary
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Preferred role                    = Primary
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Mirror status                     = Synchronized
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Status
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      PID                               = 4037
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Configuration reports status as   = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Database status                   = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Segment Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Hostname                          = sdw1
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Address                           = sdw1
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Datadir                           = /data/mirror/gpseg3
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Port                              = 7001
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Mirroring Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Current role                      = Mirror
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Preferred role                    = Mirror
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Mirror status                     = Streaming
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Replication Info
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      WAL Sent Location                 = 0/C040B10
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      WAL Flush Location                = 0/C040B10
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      WAL Replay Location               = 0/C040B10
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-   Status
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      PID                               = 3890
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Configuration reports status as   = Up
20201118:16:08:09:003865 gpstate:mdw:gpadmin-[INFO]:-      Segment status                    = Up
```

### 2. 启动、停止、重启 GP 集群

进入 GP 的 Master 节点，切换为`gpadmin`账号.

```console
$ su - gpadmin
```

#### 2.1 启动

```console
[gpadmin@mdw ~]$ gpstart 
20201118:14:15:01:001256 gpstart:mdw:gpadmin-[INFO]:-Starting gpstart with args: 
20201118:14:15:01:001256 gpstart:mdw:gpadmin-[INFO]:-Gathering information and validating the environment...
20201118:14:15:01:001256 gpstart:mdw:gpadmin-[INFO]:-Greenplum Binary Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'

. . .

Continue with Greenplum instance startup Yy|Nn (default=N):
> y
20201118:14:15:05:001256 gpstart:mdw:gpadmin-[INFO]:-Commencing parallel primary and mirror segment instance startup, please wait...
.............................................
20201118:14:15:51:001256 gpstart:mdw:gpadmin-[INFO]:-Process results...

. . .

20201118:14:16:01:001256 gpstart:mdw:gpadmin-[INFO]:-Database successfully started
```

#### 2.2 停止

```console
[gpadmin@mdw ~]$ gpstop -a -M fast
20201118:14:20:58:001354 gpstop:mdw:gpadmin-[INFO]:-Starting gpstop with args: -a -M fast
20201118:14:20:58:001354 gpstop:mdw:gpadmin-[INFO]:-Gathering information and validating the environment...
20201118:14:20:58:001354 gpstop:mdw:gpadmin-[INFO]:-Obtaining Greenplum Master catalog information
20201118:14:20:58:001354 gpstop:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20201118:14:20:59:001354 gpstop:mdw:gpadmin-[INFO]:-Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
20201118:14:20:59:001354 gpstop:mdw:gpadmin-[INFO]:-Commencing Master instance shutdown with mode='fast'
20201118:14:20:59:001354 gpstop:mdw:gpadmin-[INFO]:-Master segment instance directory=/data/master/gpseg-1
20201118:14:20:59:001354 gpstop:mdw:gpadmin-[INFO]:-Attempting forceful termination of any leftover master process
20201118:14:20:59:001354 gpstop:mdw:gpadmin-[INFO]:-Terminating processes for segment /data/master/gpseg-1
20201118:14:20:59:001354 gpstop:mdw:gpadmin-[INFO]:-Stopping master standby host smdw mode=fast

. . .

20201118:14:21:04:001354 gpstop:mdw:gpadmin-[INFO]:-Database successfully shutdown with no errors reported
20201118:14:21:04:001354 gpstop:mdw:gpadmin-[INFO]:-Cleaning up leftover gpmmon process
20201118:14:21:04:001354 gpstop:mdw:gpadmin-[INFO]:-No leftover gpmmon process found
20201118:14:21:04:001354 gpstop:mdw:gpadmin-[INFO]:-Cleaning up leftover gpsmon processes
20201118:14:21:04:001354 gpstop:mdw:gpadmin-[INFO]:-No leftover gpsmon processes on some hosts. not attempting forceful termination on these hosts
20201118:14:21:04:001354 gpstop:mdw:gpadmin-[INFO]:-Cleaning up leftover shared memory
```

#### 2.3 重启

```console
[gpadmin@mdw ~]$ gpstop -ar -M fast
20201118:14:22:51:001542 gpstop:mdw:gpadmin-[INFO]:-Starting gpstop with args: -ar -M fast
20201118:14:22:51:001542 gpstop:mdw:gpadmin-[INFO]:-Gathering information and validating the environment...
20201118:14:22:51:001542 gpstop:mdw:gpadmin-[INFO]:-Obtaining Greenplum Master catalog information
20201118:14:22:51:001542 gpstop:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20201118:14:22:51:001542 gpstop:mdw:gpadmin-[INFO]:-Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
20201118:14:22:51:001542 gpstop:mdw:gpadmin-[INFO]:-Commencing Master instance shutdown with mode='fast'

. . .

20201118:14:22:54:001542 gpstop:mdw:gpadmin-[INFO]:-Database successfully shutdown with no errors reported
20201118:14:22:54:001542 gpstop:mdw:gpadmin-[INFO]:-Cleaning up leftover gpmmon process
20201118:14:22:54:001542 gpstop:mdw:gpadmin-[INFO]:-No leftover gpmmon process found
20201118:14:22:54:001542 gpstop:mdw:gpadmin-[INFO]:-Cleaning up leftover gpsmon processes
20201118:14:22:54:001542 gpstop:mdw:gpadmin-[INFO]:-No leftover gpsmon processes on some hosts. not attempting forceful termination on these hosts
20201118:14:22:54:001542 gpstop:mdw:gpadmin-[INFO]:-Cleaning up leftover shared memory
20201118:14:22:56:001542 gpstop:mdw:gpadmin-[INFO]:-Restarting System...
```

### 3. 查看 GP 集群的状态

#### 3.1 查看 GP 集群的摘要信息

```console
[gpadmin@mdw ~]$ gpstate -b
20201118:14:24:39:001796 gpstate:mdw:gpadmin-[INFO]:-Starting gpstate with args: -b
20201118:14:24:39:001796 gpstate:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
20201118:14:24:39:001796 gpstate:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58'
20201118:14:24:39:001796 gpstate:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20201118:14:24:39:001796 gpstate:mdw:gpadmin-[INFO]:-Gathering data from segments...
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-Greenplum instance status summary
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Master instance                                           = Active
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Master standby                                            = smdw
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Standby master state                                      = Standby host passive
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total segment instance count from metadata                = 8
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Primary Segment Status
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total primary segments                                    = 4
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total primary segment valid (at master)                   = 4
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total primary segment failures (at master)                = 0
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid files missing              = 0
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid files found                = 4
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid PIDs missing               = 0
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid PIDs found                 = 4
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number of /tmp lock files missing                   = 0
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number of /tmp lock files found                     = 4
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number postmaster processes missing                 = 0
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number postmaster processes found                   = 4
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Mirror Segment Status
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total mirror segments                                     = 4
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total mirror segment valid (at master)                    = 4
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total mirror segment failures (at master)                 = 0
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid files missing              = 0
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid files found                = 4
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid PIDs missing               = 0
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid PIDs found                 = 4
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number of /tmp lock files missing                   = 0
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number of /tmp lock files found                     = 4
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number postmaster processes missing                 = 0
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number postmaster processes found                   = 4
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number mirror segments acting as primary segments   = 0
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-   Total number mirror segments acting as mirror segments    = 4
20201118:14:24:40:001796 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
```

#### 3.2 查看 GP 集群的镜像(Mirrors)状态信息

```console
[gpadmin@mdw ~]$ gpstate -m
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:-Starting gpstate with args: -m
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58'
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:--------------------------------------------------------------
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:--Current GPDB mirror list and status
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:--Type = Group
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:--------------------------------------------------------------
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:-   Mirror   Datadir               Port   Status    Data Status    
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:-   smdw     /data/mirror/gpseg0   7000   Passive   Synchronized
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:-   smdw     /data/mirror/gpseg1   7001   Passive   Synchronized
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:-   sdw1     /data/mirror/gpseg2   7000   Passive   Synchronized
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:-   sdw1     /data/mirror/gpseg3   7001   Passive   Synchronized
20201118:14:25:02:001859 gpstate:mdw:gpadmin-[INFO]:--------------------------------------------------------------
```

#### 3.3 查看 GP 集群的 Master 和 Standby 状态信息

```console
[gpadmin@mdw ~]$ gpstate -f
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:-Starting gpstate with args: -f
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58'
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:-Standby master details
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:-----------------------
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:-   Standby address          = smdw
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:-   Standby data directory   = /data/master/gpseg-1
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:-   Standby port             = 5432
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:-   Standby PID              = 2446
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:-   Standby status           = Standby host passive
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:--------------------------------------------------------------
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:--pg_stat_replication
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:--------------------------------------------------------------
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:--WAL Sender State: streaming
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:--Sync state: sync
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:--Sent Location: 0/1C0005C8
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:--Flush Location: 0/1C0005C8
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:--Replay Location: 0/1C0005C8
20201118:14:25:11:001883 gpstate:mdw:gpadmin-[INFO]:--------------------------------------------------------------
```

#### 3.4 查看 GP 集群的 Segment Mirroring 的状态信息

```console
[gpadmin@mdw ~]$ gpstate -e
20201118:14:28:44:001911 gpstate:mdw:gpadmin-[INFO]:-Starting gpstate with args: -e
20201118:14:28:44:001911 gpstate:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
20201118:14:28:44:001911 gpstate:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58'
20201118:14:28:44:001911 gpstate:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20201118:14:28:44:001911 gpstate:mdw:gpadmin-[INFO]:-Gathering data from segments...
20201118:14:28:45:001911 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:14:28:45:001911 gpstate:mdw:gpadmin-[INFO]:-Segment Mirroring Status Report
20201118:14:28:45:001911 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20201118:14:28:45:001911 gpstate:mdw:gpadmin-[INFO]:-All segments are running normally
```

### 4. Master 故障修复

#### 4.1 关闭 Master 节点，模拟 Master 节点故障

```console
[gpadmin@mdw ~]$ gpstop -am
20201118:14:35:16:002192 gpstop:mdw:gpadmin-[INFO]:-Starting gpstop with args: -am
20201118:14:35:16:002192 gpstop:mdw:gpadmin-[INFO]:-Gathering information and validating the environment...
20201118:14:35:16:002192 gpstop:mdw:gpadmin-[INFO]:-Obtaining Greenplum Master catalog information
20201118:14:35:16:002192 gpstop:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20201118:14:35:16:002192 gpstop:mdw:gpadmin-[INFO]:-Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
20201118:14:35:16:002192 gpstop:mdw:gpadmin-[INFO]:-Commencing Master instance shutdown with mode='smart'
20201118:14:35:16:002192 gpstop:mdw:gpadmin-[INFO]:-Master segment instance directory=/data/master/gpseg-1
20201118:14:35:16:002192 gpstop:mdw:gpadmin-[INFO]:-Stopping master segment and waiting for user connections to finish ...
server shutting down
20201118:14:35:17:002192 gpstop:mdw:gpadmin-[INFO]:-Attempting forceful termination of any leftover master process
20201118:14:35:17:002192 gpstop:mdw:gpadmin-[INFO]:-Terminating processes for segment /data/master/gpseg-1
```

#### 4.2 错误信息显示 

```console
[gpadmin@mdw ~]$ psql 
psql: could not connect to server: Connection refused
    Is the server running on host "mdw" (192.168.147.130) and accepting
    TCP/IP connections on port 5432?
```

#### 4.3 修复方案

- Master 节点的宿主机(host)可以恢复

    1. 恢复 Master 节点的宿主机
    2. 在 Master 节点，使用 gpadmin 账号，运行 `gpstart` 启动并恢复集群

        ```console
        [gpadmin@mdw ~]$ gpstart 
        20201118:14:43:16:002233 gpstart:mdw:gpadmin-[INFO]:-Starting gpstart with args: 
        20201118:14:43:16:002233 gpstart:mdw:gpadmin-[INFO]:-Gathering information and validating the environment...
        20201118:14:43:16:002233 gpstart:mdw:gpadmin-[INFO]:-Greenplum Binary Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
        20201118:14:43:16:002233 gpstart:mdw:gpadmin-[INFO]:-Greenplum Catalog Version: '301908232'
        
        . . .
        
        20201118:14:43:22:002233 gpstart:mdw:gpadmin-[INFO]:-Database successfully started
        ```

- Master 节点的宿主机(host)不可恢复

    1. 在 Standby 节点，运行 `gpactivatestandby` 将 Standby 激活为 Master.

        1.1 查看 GP 集群的 Standby 信息
        
        ```console
        [gpadmin@smdw ~]$ gpstate -f
        20201118:14:45:38:004248 gpstate:smdw:gpadmin-[INFO]:-Starting gpstate with args: -f
        20201118:14:45:38:004248 gpstate:smdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
        20201118:14:45:38:004248 gpstate:smdw:gpadmin-[CRITICAL]:-gpstate failed. (Reason='FATAL:  the database system is in recovery mode
        DETAIL:  last replayed record at 0/1C000988
        - VERSION: PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58
        ') exiting...
        ```

        1.2 运行 `gpactivatestandby` 将 Standby 激活为 Master.

        ```console
        [gpadmin@smdw ~]$ gpactivatestandby 
        20201118:14:45:58:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-Option -d or --master-data-directory not set. Checking environment variable MASTER_DATA_DIRECTORY
        20201118:14:45:58:004280 gpactivatestandby:smdw:gpadmin-[DEBUG]:-Running Command: ps -ef | grep postgres | grep -v grep | awk '{print $2}' | grep \`cat /data/master/gpseg-1/postmaster.pid | head -1\` || echo -1
        20201118:14:45:59:004280 gpactivatestandby:smdw:gpadmin-[INFO]:------------------------------------------------------
        20201118:14:45:59:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-Standby data directory    = /data/master/gpseg-1
        20201118:14:45:59:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-Standby port              = 5432
        20201118:14:45:59:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-Standby running           = yes
        20201118:14:45:59:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-Force standby activation  = no
        20201118:14:45:59:004280 gpactivatestandby:smdw:gpadmin-[INFO]:------------------------------------------------------
        20201118:14:45:59:004280 gpactivatestandby:smdw:gpadmin-[DEBUG]:-Running Command: cat /tmp/.s.PGSQL.5432.lock
        Do you want to continue with standby master activation? Yy|Nn (default=N):
        > y

        . . .

        20201118:14:46:03:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-Promoting standby...
        20201118:14:46:03:004280 gpactivatestandby:smdw:gpadmin-[DEBUG]:-Running Command: pg_ctl promote -D /data/master/gpseg-1
        20201118:14:46:03:004280 gpactivatestandby:smdw:gpadmin-[DEBUG]:-Waiting for connection...
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-Standby master is promoted
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-Reading current configuration...
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[DEBUG]:-Connecting to dbname='postgres'
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:------------------------------------------------------
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-The activation of the standby master has completed successfully.
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-smdw is now the new primary master.
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-You will need to update your user access mechanism to reflect
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-the change of master hostname.
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-Do not re-start the failed master while the fail-over master is
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-operational, this could result in database corruption!
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-MASTER_DATA_DIRECTORY is now /data/master/gpseg-1 if
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-this has changed as a result of the standby master activation, remember
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-to change this in any startup scripts etc, that may be configured
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-to set this value.
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-MASTER_PORT is now 5432, if this has changed, you
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-may need to make additional configuration changes to allow access
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-to the Greenplum instance.
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-Refer to the Administrator Guide for instructions on how to re-activate
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-the master to its previous state once it becomes available.
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-Query planner statistics must be updated on all databases
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-following standby master activation.
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:-When convenient, run ANALYZE against all user databases.
        20201118:14:46:07:004280 gpactivatestandby:smdw:gpadmin-[INFO]:------------------------------------------------------
        ```

        1.3 查看 GP 集群的状态信息（注意此时显示无 Standby 配置）

        ```console
        [gpadmin@smdw ~]$ gpstate -b
        20201118:14:46:23:004347 gpstate:smdw:gpadmin-[INFO]:-Starting gpstate with args: -b
        20201118:14:46:23:004347 gpstate:smdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
        20201118:14:46:23:004347 gpstate:smdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58'
        20201118:14:46:23:004347 gpstate:smdw:gpadmin-[INFO]:-Obtaining Segment details from master...
        20201118:14:46:23:004347 gpstate:smdw:gpadmin-[INFO]:-Gathering data from segments...
        .
        20201118:14:46:25:004347 gpstate:smdw:gpadmin-[INFO]:-Greenplum instance status summary
        20201118:14:46:25:004347 gpstate:smdw:gpadmin-[INFO]:-----------------------------------------------------
        20201118:14:46:25:004347 gpstate:smdw:gpadmin-[INFO]:-   Master instance                                           = Active
        20201118:14:46:25:004347 gpstate:smdw:gpadmin-[INFO]:-   Master standby                                            = No master standby configured
        20201118:14:46:25:004347 gpstate:smdw:gpadmin-[INFO]:-   Total segment instance count from metadata                = 8
        20201118:14:46:25:004347 gpstate:smdw:gpadmin-[INFO]:-----------------------------------------------------

        . . .

        ```

        1.4 恢复原来的 Master 宿主机，并将 Master 节点还原。

        在当前 Master 宿主机(smdw)，执行`gpinitstandby -s mdw`，将原 mdw 节点配置 Standby 节点

        ```console
        $ gpinitstandby -s mdw
        20201118:15:15:44:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Validating environment and parameters for standby initialization...
        20201118:15:15:44:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Checking for data directory /data/master/gpseg-1 on mdw
        20201118:15:15:45:004661 gpinitstandby:smdw:gpadmin-[INFO]:------------------------------------------------------
        20201118:15:15:45:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Greenplum standby master initialization parameters
        20201118:15:15:45:004661 gpinitstandby:smdw:gpadmin-[INFO]:------------------------------------------------------
        20201118:15:15:45:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Greenplum master hostname               = smdw
        20201118:15:15:45:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Greenplum master data directory         = /data/master/gpseg-1
        20201118:15:15:45:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Greenplum master port                   = 5432
        20201118:15:15:45:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Greenplum standby master hostname       = mdw
        20201118:15:15:45:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Greenplum standby master port           = 5432
        20201118:15:15:45:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Greenplum standby master data directory = /data/master/gpseg-1
        20201118:15:15:45:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Greenplum update system catalog         = On
        Do you want to continue with standby master initialization? Yy|Nn (default=N):
        > y
        20201118:15:15:47:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Syncing Greenplum Database extensions to standby
        20201118:15:15:47:004661 gpinitstandby:smdw:gpadmin-[WARNING]:-Syncing of Greenplum Database extensions has failed.
        20201118:15:15:47:004661 gpinitstandby:smdw:gpadmin-[WARNING]:-Please run gppkg --clean after successful standby initialization.
        20201118:15:15:47:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Adding standby master to catalog...
        20201118:15:15:47:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Database catalog updated successfully.
        20201118:15:15:47:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Updating pg_hba.conf file...
        20201118:15:15:48:004661 gpinitstandby:smdw:gpadmin-[INFO]:-pg_hba.conf files updated successfully.
        20201118:15:15:55:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Starting standby master
        20201118:15:15:55:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Checking if standby master is running on host: mdw  in directory: /data/master/gpseg-1
        20201118:15:16:04:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Cleaning up pg_hba.conf backup files...
        20201118:15:16:06:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Backup files of pg_hba.conf cleaned up successfully.
        20201118:15:16:06:004661 gpinitstandby:smdw:gpadmin-[INFO]:-Successfully created standby master on mdw
        ```

        1.5 停止 smdw 节点，并备份 `MASTER_DATA_DIRECTORY`

        ```console
        [gpadmin@smdw ~]$ gpstop -am
        20201118:15:24:46:004871 gpstop:smdw:gpadmin-[INFO]:-Starting gpstop with args: -am
        20201118:15:24:46:004871 gpstop:smdw:gpadmin-[INFO]:-Gathering information and validating the environment...
        20201118:15:24:46:004871 gpstop:smdw:gpadmin-[INFO]:-Obtaining Greenplum Master catalog information
        20201118:15:24:46:004871 gpstop:smdw:gpadmin-[INFO]:-Obtaining Segment details from master...
        20201118:15:24:46:004871 gpstop:smdw:gpadmin-[INFO]:-Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
        20201118:15:24:46:004871 gpstop:smdw:gpadmin-[INFO]:-Commencing Master instance shutdown with mode='smart'
        20201118:15:24:46:004871 gpstop:smdw:gpadmin-[INFO]:-Master segment instance directory=/data/master/gpseg-1
        20201118:15:24:46:004871 gpstop:smdw:gpadmin-[INFO]:-Stopping master segment and waiting for user connections to finish ...
        server shutting down
        20201118:15:24:47:004871 gpstop:smdw:gpadmin-[INFO]:-Attempting forceful termination of any leftover master process
        20201118:15:24:47:004871 gpstop:smdw:gpadmin-[INFO]:-Terminating processes for segment /data/master/gpseg-1
        [gpadmin@smdw ~]$ mv /data/master/gpseg-1/ /data/master/gpseg-1.ba
        ```

        1.6 进入 mdw 宿主机，使用 gpadmin 账号，将 mdw 激活为 Standby，并将 smdw 重新配置为 Standby

        ```console
        [gpadmin@mdw ~]$ gpactivatestandby 
        20201118:15:27:17:002952 gpactivatestandby:mdw:gpadmin-[INFO]:-Option -d or --master-data-directory not set. Checking environment variable MASTER_DATA_DIRECTORY
        . . .

        20201118:15:27:19:002952 gpactivatestandby:mdw:gpadmin-[INFO]:------------------------------------------------------
        20201118:15:27:19:002952 gpactivatestandby:mdw:gpadmin-[INFO]:-The activation of the standby master has completed successfully.

        . . .

        [gpadmin@mdw ~]$ gpinitstandby -s smdw
        20201118:15:27:58:003008 gpinitstandby:mdw:gpadmin-[INFO]:-Validating environment and parameters for standby initialization...

        . . .

        20201118:15:28:15:003008 gpinitstandby:mdw:gpadmin-[INFO]:-Successfully created standby master on smdw
        ```

### 4. Segment 故障修复

#### 4.1 模拟 GP 集群节点故障

进入 Segment 宿主机 sdw1，强行停止 GP 集群的相关进程，模拟 GP 集群节点故障

```console
[gpadmin@sdw1 ~]$ pkill postgres
[gpadmin@sdw1 ~]$ ps aux | grep post
root        951  0.0  0.1  89704  2128 ?        Ss   14:01   0:00 /usr/libexec/postfix/master -w
postfix     953  0.0  0.2  89876  4088 ?        S    14:01   0:00 qmgr -l -t unix -u
postfix    1144  0.0  0.2  89808  4068 ?        S    14:02   0:00 pickup -l -t unix -u
gpadmin    3291  0.0  0.0 112812   968 pts/0    R+   15:34   0:00 grep --color=auto post
```

#### 4.2 查看集群的 Mirror 状态

进入 Master 节点 mdw，执行 `gpstate -m` 查看集群的 Mirror 状态，我们发现 Mirror Segment 的角色被激活为 Primary，并发现名为 sdw1 的 Segment Host 存在两个失败的 Segment

```console
[gpadmin@mdw ~]$ gpstate -m
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-Starting gpstate with args: -m
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58'
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:--------------------------------------------------------------
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:--Current GPDB mirror list and status
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:--Type = Group
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:--------------------------------------------------------------
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-   Mirror   Datadir               Port   Status              Data Status   
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-   smdw     /data/mirror/gpseg0   7000   Acting as Primary   Not In Sync
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-   smdw     /data/mirror/gpseg1   7001   Acting as Primary   Not In Sync
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[WARNING]:-sdw1     /data/mirror/gpseg2   7000   Failed                            <<<<<<<<
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[WARNING]:-sdw1     /data/mirror/gpseg3   7001   Failed                            <<<<<<<<
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:--------------------------------------------------------------
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[WARNING]:-2 segment(s) configured as mirror(s) are acting as primaries
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[WARNING]:-2 segment(s) configured as mirror(s) have failed
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[WARNING]:-2 mirror segment(s) acting as primaries are not synchronized
```

我们也可以直接使用 `gpstate -e` 检查失败的 Segment 信息。

```console
[gpadmin@mdw ~]$ gpstate -m
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-Starting gpstate with args: -m
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58'
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:--------------------------------------------------------------
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:--Current GPDB mirror list and status
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:--Type = Group
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:--------------------------------------------------------------
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-   Mirror   Datadir               Port   Status              Data Status   
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-   smdw     /data/mirror/gpseg0   7000   Acting as Primary   Not In Sync
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:-   smdw     /data/mirror/gpseg1   7001   Acting as Primary   Not In Sync
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[WARNING]:-sdw1     /data/mirror/gpseg2   7000   Failed                            <<<<<<<<
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[WARNING]:-sdw1     /data/mirror/gpseg3   7001   Failed                            <<<<<<<<
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[INFO]:--------------------------------------------------------------
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[WARNING]:-2 segment(s) configured as mirror(s) are acting as primaries
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[WARNING]:-2 segment(s) configured as mirror(s) have failed
20201118:15:38:56:003347 gpstate:mdw:gpadmin-[WARNING]:-2 mirror segment(s) acting as primaries are not synchronized
```

我们也可以运行 `gpstate -s` 查看 GP 集群详细的状态。

#### 4.3 分布式高可用的 GP 集群，自动修复了单点故障

特别强调的是，因为我们启用 Segment Mirroring，使得分布式的 GP 集群具有单点故障自动修复能力，即现在集群依然处于可用状态。

```console
[gpadmin@mdw ~]$ psql 
psql (9.4.24)
Type "help" for help.

postgres=# select * from gp_segment_configuration;
 dbid | content | role | preferred_role | mode | status | port | hostname | address |       datadir        
------+---------+------+----------------+------+--------+------+----------+---------+----------------------
   13 |      -1 | p    | p              | s    | u      | 5432 | mdw      | mdw     | /data/master/gpseg-1
   14 |      -1 | m    | m              | s    | u      | 5432 | smdw     | smdw    | /data/master/gpseg-1
    4 |       2 | p    | p              | n    | u      | 6000 | smdw     | smdw    | /data/primary/gpseg2
    9 |       2 | m    | m              | n    | d      | 7000 | sdw1     | sdw1    | /data/mirror/gpseg2
    5 |       3 | p    | p              | n    | u      | 6001 | smdw     | smdw    | /data/primary/gpseg3
   10 |       3 | m    | m              | n    | d      | 7001 | sdw1     | sdw1    | /data/mirror/gpseg3
    2 |       0 | m    | p              | n    | d      | 6000 | sdw1     | sdw1    | /data/primary/gpseg0
    7 |       0 | p    | m              | n    | u      | 7000 | smdw     | smdw    | /data/mirror/gpseg0
    3 |       1 | m    | p              | n    | d      | 6001 | sdw1     | sdw1    | /data/primary/gpseg1
    8 |       1 | p    | m              | n    | u      | 7001 | smdw     | smdw    | /data/mirror/gpseg1
(10 rows)

postgres=# \q
```

#### 4.4 修复失败的 Segment

1. 修复失败的 Segment

    ```console
    [gpadmin@mdw ~]$ gprecoverseg -qo recoverseg
    [gpadmin@mdw ~]$ cat recoverseg 
    sdw1|6000|/data/primary/gpseg0
    sdw1|6001|/data/primary/gpseg1
    sdw1|7000|/data/mirror/gpseg2
    sdw1|7001|/data/mirror/gpseg3
    [gpadmin@mdw ~]$ gprecoverseg -i recoverseg 
    20201118:15:50:11:003544 gprecoverseg:mdw:gpadmin-[INFO]:-Starting gprecoverseg with args: -i recoverseg
    20201118:15:50:11:003544 gprecoverseg:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
    20201118:15:50:11:003544 gprecoverseg:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58'
    20201118:15:50:11:003544 gprecoverseg:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
    20201118:15:50:12:003544 gprecoverseg:mdw:gpadmin-[INFO]:-Heap checksum setting is consistent between master and the segments that are candidates for recoverseg
    20201118:15:50:12:003544 gprecoverseg:mdw:gpadmin-[INFO]:-Greenplum instance recovery parameters
    20201118:15:50:12:003544 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
    20201118:15:50:12:003544 gprecoverseg:mdw:gpadmin-[INFO]:-Recovery from configuration -i option supplied
    20201118:15:50:12:003544 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
    
    . . .
    
    Continue with segment recovery procedure Yy|Nn (default=N):
    > y
    
    . . .
    
    20201118:15:50:33:003544 gprecoverseg:mdw:gpadmin-[INFO]:-Process results...
    20201118:15:50:33:003544 gprecoverseg:mdw:gpadmin-[INFO]:-Triggering FTS probe
    20201118:15:50:33:003544 gprecoverseg:mdw:gpadmin-[INFO]:-******************************************************************
    20201118:15:50:33:003544 gprecoverseg:mdw:gpadmin-[INFO]:-Updating segments for streaming is completed.
    20201118:15:50:33:003544 gprecoverseg:mdw:gpadmin-[INFO]:-For segments updated successfully, streaming will continue in the background.
    20201118:15:50:33:003544 gprecoverseg:mdw:gpadmin-[INFO]:-Use  gpstate -s  to check the streaming progress.
    20201118:15:50:33:003544 gprecoverseg:mdw:gpadmin-[INFO]:-******************************************************************
    ```

2. 查看 Segment Mirror 的状态信息

    我们发现有两个 Segment 的 Mirror 被激活为 Primary，下一步需要重新平衡 GP 集群的存储和计算资源.
    
    
    ```console
    [gpadmin@mdw ~]$ gpstate -e
    20201118:15:50:59:003633 gpstate:mdw:gpadmin-[INFO]:-Starting gpstate with args: -e
    20201118:15:50:59:003633 gpstate:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
    20201118:15:50:59:003633 gpstate:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58'
    20201118:15:50:59:003633 gpstate:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
    20201118:15:50:59:003633 gpstate:mdw:gpadmin-[INFO]:-Gathering data from segments...
    20201118:15:51:00:003633 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
    20201118:15:51:00:003633 gpstate:mdw:gpadmin-[INFO]:-Segment Mirroring Status Report
    20201118:15:51:00:003633 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
    20201118:15:51:00:003633 gpstate:mdw:gpadmin-[INFO]:-Segments with Primary and Mirror Roles Switched
    20201118:15:51:00:003633 gpstate:mdw:gpadmin-[INFO]:-   Current Primary   Port   Mirror   Port
    20201118:15:51:00:003633 gpstate:mdw:gpadmin-[INFO]:-   smdw              7000   sdw1     6000
    20201118:15:51:00:003633 gpstate:mdw:gpadmin-[INFO]:-   smdw              7001   sdw1     6001
    ```

3. 重新平衡 GP 集群的 Segment 分布

    ```console
    [gpadmin@mdw ~]$ gprecoverseg -r
    20201118:15:51:16:003694 gprecoverseg:mdw:gpadmin-[INFO]:-Starting gprecoverseg with args: -r
    20201118:15:51:16:003694 gprecoverseg:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
    20201118:15:51:16:003694 gprecoverseg:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58'
    20201118:15:51:16:003694 gprecoverseg:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
    20201118:15:51:16:003694 gprecoverseg:mdw:gpadmin-[INFO]:-Greenplum instance recovery parameters
    20201118:15:51:16:003694 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
    20201118:15:51:16:003694 gprecoverseg:mdw:gpadmin-[INFO]:-Recovery type              = Rebalance
    20201118:15:51:16:003694 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------

    . . .
    
    Continue with segment rebalance procedure Yy|Nn (default=N):
    > y

    . . .

    20201118:15:51:34:003694 gprecoverseg:mdw:gpadmin-[INFO]:-******************************************************************
    20201118:15:51:34:003694 gprecoverseg:mdw:gpadmin-[INFO]:-The rebalance operation has completed successfully.
    20201118:15:51:34:003694 gprecoverseg:mdw:gpadmin-[INFO]:-There is a resynchronization running in the background to bring all
    20201118:15:51:34:003694 gprecoverseg:mdw:gpadmin-[INFO]:-segments in sync.
    20201118:15:51:34:003694 gprecoverseg:mdw:gpadmin-[INFO]:-Use gpstate -e to check the resynchronization progress.
    20201118:15:51:34:003694 gprecoverseg:mdw:gpadmin-[INFO]:-******************************************************************
    ```

    查看 GP 集群的 Segment 的 Mirror 状态信息，并验证重平衡的结果。

    ```console
    [gpadmin@mdw ~]$ gpstate -e
    20201118:15:51:39:003783 gpstate:mdw:gpadmin-[INFO]:-Starting gpstate with args: -e
    20201118:15:51:39:003783 gpstate:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa'
    20201118:15:51:39:003783 gpstate:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.4.0 build commit:564b89a8c6bef5e329a59f39dac438b13d9cb3fa) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Feb 12 2020 00:38:58'
    20201118:15:51:39:003783 gpstate:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
    20201118:15:51:39:003783 gpstate:mdw:gpadmin-[INFO]:-Gathering data from segments...
    .
    20201118:15:51:40:003783 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
    20201118:15:51:40:003783 gpstate:mdw:gpadmin-[INFO]:-Segment Mirroring Status Report
    20201118:15:51:40:003783 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
    20201118:15:51:40:003783 gpstate:mdw:gpadmin-[INFO]:-All segments are running normally
    [gpadmin@mdw ~]$ 
    ```

### 5. 补充说明

在所有 GP 的节点的宿主机正常恢复后，很多时候，我们都可以通过 `gpstop -ar -M fast` 重启 GP 集群，修复大部分的问题。
