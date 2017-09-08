---
layout: post
title: "How to Deploy a MongoDB with Docker"
date: 2017-09-08 15-37-56 +0800
categories: ['Mongo']
tags: ['Mongo']
disqus_identifier: 32306689283863169736250327311358675453
---
* TOC
{:toc}

* * *


### 1. Start a MongoDB Instance.

```sh
$ docker run -d -p 27017:27017 --name db mongo:3
```

### 2. Start the MongoDB Instance with Access Control.

```sh
$ docker run -d -p 27017:27017 --name db mongo:3 --auth
```

*Connect a mongo shell to one of the config server mongod instances over the [localhost interface](https://docs.mongodb.com/manual/core/security-users/#localhost-exception) and create the user administrator.*

```sh
$ docker exec -it db mongo admin --quiet
> db.createUser({
... user:"admin",
... pwd:"admin",
... roles: [
... {role: "userAdmin", db:"admin"}
... ]
... })
Successfully added user: {
        "user" : "admin",
        "roles" : [
                {
                        "role" : "userAdmin",
                        "db" : "admin"
                }
        ]
}
> db.auth("admin","admin")
1
```
```
> db.createUser({
... user: "user1",
... pwd: "user1",
... roles: [
... {
... role: "readWriteAnyDatabase",
... db: "admin"
... }
... ]
... })
Successfully added user: {
        "user" : "user1",
        "roles" : [
                {
                        "role" : "readWriteAnyDatabase",
                        "db" : "admin"
                }
        ]
}
> use test
switched to db test
> db.test.insertOne({ x: 1 })
2017-09-08T08:50:53.276+0000 E QUERY    [thread1] TypeError: err.hasWriteErrors ...
DBCollection.prototype.insertOne@src/mongo/shell/crud_api.js:244:13
@(shell):1:1
```
```
> db.auth("user1","user1")
Error: Authentication failed.
0
> use admin
switched to db admin
> db.auth("user1","user1")
1
> use test
switched to db test
> db.test.insertOne({ x: 1 })
{
        "acknowledged" : true,
        "insertedId" : ObjectId("59b25a108bcdfe4e19c35a13")
}
>
```

### 3. Deploy a Replica Set

```sh
$ mkdir mogors
$ cd mogors/
```
```
$ cat <<EOF > docker-compose.yml
> ---
> version: "3.2"
> services:
>     db-0:
>         container_name: db-0
>         image: mongo:3
>         # Start each member of the replica set with the appropriate options .
>         command:
>             - mongod
>             - "--replSet"
>             - "rs0"
>     db-1:
>         container_name: db-1
>         image: mongo:3
>         command:
>             - mongod
>             - "--replSet"
>             - "rs0"
>     db-2:
>         container_name: db-2
>         image: mongo:3
>         command:
>             - mongod
>             - "--replSet"
>             - "rs0"
> EOF
```
```sh
$ docker-compose up -d
Creating network "mongors_default" with the default driver
Creating db-2 ...
Creating db-0 ...
Creating db-1 ...
Creating db-2
Creating db-1
Creating db-0 ... done
$ docker ps -a
CONTAINER ID        IMAGE               STATUS              PORTS               NAMES
0f6a34b826b2        mongo:3             Up 45 seconds       27017/tcp           db-1
c4c04bfc53f3        mongo:3             Up 46 seconds       27017/tcp           db-0
9d8bc021082c        mongo:3             Up 46 seconds       27017/tcp           db-2
```

```sh
$ docker exec -it db-0 mongo --quiet
Welcome to the MongoDB shell.
For interactive help, type "help".
For more comprehensive documentation, see
        http://docs.mongodb.org/
Questions? Try the support group
        http://groups.google.com/group/mongodb-user
> rs.initiate( {
...    _id : "rs0",
...    members: [ { _id : 0, host : "db-0" } ]
... })
{ "ok" : 1 }
rs0:PRIMARY> rs.add("db-1")
{ "ok" : 1 }
rs0:PRIMARY> rs.add("db-2")
{ "ok" : 1 }
rs0:PRIMARY> db.runCommand("isMaster")
{
        "hosts" : [
                "db-0:27017",
                "db-1:27017",
                "db-2:27017"
        ],
        "setName" : "rs0",
        "setVersion" : 3,
        "ismaster" : true,
        "secondary" : false,
        "primary" : "db-0:27017",
        "me" : "db-0:27017",
        "electionId" : ObjectId("7fffffff0000000000000001"),
        "lastWrite" : {
                "opTime" : {
                        "ts" : Timestamp(1504859331, 1),
                        "t" : NumberLong(1)
                },
                "lastWriteDate" : ISODate("2017-09-08T08:28:51Z")
        },
        "maxBsonObjectSize" : 16777216,
        "maxMessageSizeBytes" : 48000000,
        "maxWriteBatchSize" : 1000,
        "localTime" : ISODate("2017-09-08T08:28:56.329Z"),
        "maxWireVersion" : 5,
        "minWireVersion" : 0,
        "readOnly" : false,
        "ok" : 1
}
rs0:PRIMARY>
```

### 4. Deploy a Replica Set with Access Control.

```sh
$ mkdir mogors
$ cd mogors/
```
```sh
$ # Create a keyfile.
$ openssl rand -base64 756 > keyfile
$ cat keyfile
AFO3EYmmmQQLF68tUd3aQsFI/C53XtOpUGt8R5ecS1F9uWRFg4dN6jlCjiBbYqHC
w3lqUhlRBe00YhDM97z31oYkQBSyID20pIMeQ3e40FY6zBE1w+4lWYekuPJAUtzS
ZspGfFExltwL0700Dwu7b1mnMbqfmfrpSVxTKHaY7Hcw60mvbBPPCp6IWkDVZ9NX
NKveHX3Wuq28/PSMw8sVPUbP5eqPux05PCyp5VBp6/fhg8Np8vIlWAy9fMsAgkmE
kBeGcRNst6t0iXbqNi9VrW6szJN5yyq0x1+0XB1QJZCjnLczoXMTPQeDCTrijbpI
N4zr7L2EV6n8FsgSJ7vwzRMj0ZRFjuK/wwBblPCuisv5JlcClZ6I0WEtV1yg5HQu
AFv3v7FPmfodQ6Sz81c6sNEKuwg3kzCY7wkeA163RZrujHViYFka6zOcv/kDdQ5h
rL6EBXE3v6bnd24/nzys9Zx6CrqPPUqSVfugmIW78r9imXswUqdr/VZVbhGsKcjH
Uza306prvuWmh0o1hpFGReGbHIdWhEtP/ldXKBbPy+27tgNeSiSP1GjVG2rkaIlb
bsnahiNj2EaAa1ov9pYiyO51m+ouEg+H9LPBcLhLXipI3wbST8BqMZweLSNfeLFi
Kpel5Q3rNtmRrjCbVIiiAXmxECU+PcwL+a4XhISnktdq6Du43d4INSJ/cn8JVLFS
VbR5nTnc4cMmEE3n/0BrScZinGZT1gbtwbE5izA5E17/7n/HLGUXhfhMGWrwdL9f
CsDt8ZEg7AUCPhFhsbcwfHkROXmYYubcd41NqLEYyktDzqsu3CaXFvH3QyD5AqmN
ylh6UGgjqgWIC7y553qNE9v7Go/9zKTUj8Df/wcQVl6ALOdZgPmchNTX8PtENdKT
aPUu/dcctYZUxz1DKwkaH3aUblSBGtSHa94knUA+R3DWPTcGNt3n46AL45Ty5amX
c5yYTpaKB6jgXwIMjO96OA9XlZKxOVgqdASsN6O0wCzfAg55
$ chmod 400 keyfile
$ sudo chown 999 keyfile
```

```sh
$ cat docker-compose.yml
---
version: "3.2"
services:
    db-0:
        container_name: db-0
        image: mongo:3
        # Start each member of the replica set with the appropriate options .
        command:
            - mongod
            - "--replSet"
            - "rs0"
            - "--auth"
            - "--keyFile"
            - "/opt/mongors/keyfile"
        volumes:
            - type: bind
              source: ./keyfile
              target: /opt/mongors/keyfile
              read_only: true
    db-1:
        container_name: db-1
        image: mongo:3
        command:
            - mongod
            - "--replSet"
            - "rs0"
            - "--auth"
            - "--keyFile"
            - "/opt/mongors/keyfile"
        volumes:
            - type: bind
              source: ./keyfile
              target: /opt/mongors/keyfile
    db-2:
        container_name: db-2
        image: mongo:3
        command:
            - mongod
            - "--replSet"
            - "rs0"
            - "--auth"
            - "--keyFile"
            - "/opt/mongors/keyfile"
        volumes:
            - type: bind
              source: ./keyfile
              target: /opt/mongors/keyfile
```
```sh
$ docker-compose up -d
Creating network "mongors_default" with the default driver
Creating db-1 ...
Creating db-0 ...
Creating db-1
Creating db-0
Creating db-2 ...
Creating db-2 ... done
$ docker ps -a
CONTAINER ID        IMAGE               STATUS              PORTS               NAMES
02143821d0d7        mongo:3             Up 3 seconds        27017/tcp           db-2
338aef4ef282        mongo:3             Up 3 seconds        27017/tcp           db-0
ff459a50af25        mongo:3             Up 3 seconds        27017/tcp           db-1
```
```sh
$ docker exec -it db-0 mongo --quiet
> rs.initiate( {
...    _id : "rs0",
...    members: [ { _id : 0, host : "db-0" } ]
... })
{ "ok" : 1 }
rs0:SECONDARY> use admin
switched to db admin
rs0:PRIMARY> db.createUser({
... user:"admin",
... pwd:"admin",
... roles: [
... {role: "userAdmin", db:"admin"},
... {role: "clusterAdmin", db: "admin"}
... ]
... })
Successfully added user: {
        "user" : "admin",
        "roles" : [
                {
                        "role" : "userAdmin",
                        "db" : "admin"
                },
                {
                        "role" : "clusterAdmin",
                        "db" : "admin"
                }
        ]
}
rs0:PRIMARY> rs.add('db-1')
2017-09-08T09:44:33.194+0000 E QUERY    [thread1] Error: count failed: {
        "ok" : 0,
        "errmsg" : "not authorized on local to execute command ...
        "code" : 13,
        "codeName" : "Unauthorized"
} :
_getErrorWithCode@src/mongo/shell/utils.js:25:13
DBQuery.prototype.count@src/mongo/shell/query.js:383:11
DBCollection.prototype.count@src/mongo/shell/collection.js:1700:12
rs.add@src/mongo/shell/utils.js:1227:1
@(shell):1:1
```
```
rs0:PRIMARY> db.auth('admin','admin')
1
rs0:PRIMARY> rs.add('db-1')
{ "ok" : 1 }
rs0:PRIMARY> rs.add('db-2')
{ "ok" : 1 }
rs0:PRIMARY> db.runCommand("isMaster")
{
        "hosts" : [
                "db-0:27017",
                "db-1:27017",
                "db-2:27017"
        ],
        "setName" : "rs0",
        "setVersion" : 3,
        "ismaster" : true,
        "secondary" : false,
        "primary" : "db-0:27017",
        "me" : "db-0:27017",
        "electionId" : ObjectId("7fffffff0000000000000001"),
        "lastWrite" : {
                "opTime" : {
                        "ts" : Timestamp(1504863894, 1),
                        "t" : NumberLong(1)
                },
                "lastWriteDate" : ISODate("2017-09-08T09:44:54Z")
        },
        "maxBsonObjectSize" : 16777216,
        "maxMessageSizeBytes" : 48000000,
        "maxWriteBatchSize" : 1000,
        "localTime" : ISODate("2017-09-08T09:45:04.775Z"),
        "maxWireVersion" : 5,
        "minWireVersion" : 0,
        "readOnly" : false,
        "ok" : 1
}
rs0:PRIMARY>
```

### References:

1. [mongo \| Docker Documentation](https://docs.docker.com/samples/library/mongo/#authentication-and-authorization)
1. [Enable Auth — MongoDB Tutorials](https://docs.mongodb.com/tutorials/enable-authentication/)
2. [Manage Users and Roles — MongoDB Tutorials](https://docs.mongodb.com/tutorials/manage-users-and-roles/)
3. [Built-In Roles — MongoDB Manual 3.4](https://docs.mongodb.com/manual/reference/built-in-roles/)
1. [Deploy a Replica Set — MongoDB Manual 3.4](https://docs.mongodb.com/manual/tutorial/deploy-replica-set/)
1. [Enforce Keyfile Access Control in a Replica Set — MongoDB Manual 3.4](https://docs.mongodb.com/manual/tutorial/enforce-keyfile-access-control-in-existing-replica-set/)
1. [Compose file version 3 reference \| Docker Documentation](https://docs.docker.com/compose/compose-file/)
1. [Deploy a MongoDB Cluster in 9 steps Using Docker](https://medium.com/@gargar454/deploy-a-mongodb-cluster-in-steps-9-using-docker-49205e231319)
1. [Mongodb KeyFile too open permissions - Stack Overflow](https://stackoverflow.com/questions/14789622/mongodb-keyfile-too-open-permissions)
