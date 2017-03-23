---
layout: post
title: "Review Terms in Database System Concepts"
date: 2017-03-18 10-54-38 +0800
categories: ['Database']
tags: ['Database']
disqus_identifier: 200638505825154188109093812439264257291
---
* TOC
{:toc}

- - -

### Chapter 1 Introduction

```txt
• Database-management system (DBMS)
• Database-system applications
• File-processing systems
• Data inconsistency
• Consistency constraints
• Data abstraction
• Instance
• Schema
    ◦  Physical schema
    ◦  Logical schema
• Physical data independence
• Data models
    ◦  Entity-relationship model
    ◦  Relational data model
    ◦  Object-based data model
    ◦  Semistructured data model
• Database languages
    ◦  Data-definition language
    ◦  Data-manipulation language
    ◦  Query language
• Metadata
• Application program
• Normalization
• Data dictionary
• Storage manager
• Query processor
• Transactions
    ◦  Atomicity
    ◦  Failure recovery
    ◦  Concurrency control
• Two- and three-tier database architectures
• Data mining
• Database administrator (DBA)
```

* * *

### Chapter 2 Introduction to the Relational Model

```txt
• Table
• Relation
• Tuple
• Attribute
• Domain
• Atomic domain
• Null value
• Database schema
• Database instance
• Relation schema
• Relation instance
• Keys
    ◦  Superkey
    ◦  Candidate key
    ◦  Primary key
• Foreign key
    ◦  Referencing relation
    ◦  Referenced relation
• Referential integrity constraint
• Schema diagram
• Query language
    ◦  Procedural language
    ◦  Nonprocedural language
• Operations on relations
    ◦  Selection of tuples
    ◦  Selection of attributes
    ◦  Natural join
    ◦  Cartesian product
    ◦  Set operations
• Relational algebra
```

* * *

### Chapter 3 Introduction to SQL

```txt
• Data-definition language
• Data-manipulation language
• Database schema
• Database instance
• Relation schema
• Relation instance
• Primary key
• Foreign key
    ◦ Referencing relation
    ◦ Referenced relation
• Null value
• Query language
• SQL query structure
    ◦ select clause
    ◦ from clause
    ◦ where clause
• Natural join operation
• as clause
• order by clause
• Correlation name (correlation variable, tuple variable)
• Set operations
    ◦ union
    ◦ intersect
    ◦ except
• Null values
    ◦ Truth value “unknown”
• Aggregate functions
    ◦ avg, min, max, sum, count
    ◦ group by
    ◦ having
• Nested subqueries
• Set comparisons
    ◦ {<,<=,>,>=} { some, all }
    ◦ exists
    ◦ unique
• lateral clause
• with clause
• Scalar subquery
• Database modification
    ◦ Deletion
    ◦ Insertion
    ◦ Updating
```

- - -

### Chapter 4 Intermediate SQL

```txt
• Join types
    ◦ Inner and outer join
    ◦ Left, right and full outer join
    ◦ Natural, using, and on
• View definition
• Materialized views
• View update
• Transactions
    ◦ Commit work
    ◦ Rollback work
    ◦ Atomic transaction
• Integrity constraints
• Domain constraints
• Unique constraint
• Check clause
• Referential integrity
    ◦ Cascading deletes
    ◦ Cascading updates
• Assertions
• Date and time types
• Default values
• Indices
• Large objects
• User-defined types
• Domains
• Catalogs
• Schemas
• Authorization
• Privileges
    ◦ select
    ◦ insert
    ◦ update
    ◦ all privileges
    ◦ Granting of privileges
    ◦ Revoking of privileges
    ◦ Privilege to grant privileges
    ◦ Grant option
• Roles
• Authorization on views
• Execute authorization
• Invoker privileges
• Row-level authorization
```

* * *

### Chapter 5 Advanced SQL

```txt
• JDBC
• ODBC
• Prepared statements
• Accessing metadata
• SQL injection
• Embedded SQL
• Cursors
• Updatable cursors
• Dynamic SQL
• SQL functions
• Stored procedures
• Procedural constructs
• External language routines
• Trigger
• Before and after triggers
• Transition variables and tables
• Recursive queries
• Monotonic queries
• Ranking functions
    ◦ Rank
    ◦ Dense rank
    ◦ Partition by
• Windowing
• Online analytical processing (OLAP)
• Multidimensional data
    ◦ Measure attributes
    ◦ Dimension attributes
    ◦ Pivoting
    ◦ Data cube
    ◦ Slicing and dicing
    ◦ Rollup and drill down
• Cross-tabulation
```

* * *

### References

1. [Database.System.Concepts(6th.Edition.2010).Abraham.Silberschatz]()
