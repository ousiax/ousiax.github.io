---
layout: post
title: "Alex Petrov - Database Internals"
date: 2020-05-07 07:53:12 +0800
categories: ['database']
tags: ['database']
---

Databases are modular systems and consist of multiple parts: a **transport layer**
accepting requests, a **query processor** determining the most efficient way to
run queries, an **execution engine** carrying out the operations, and a **storage
engine**.

- - -

The storage engine (or database engine) is a software component of a
database management system responsible for storing, retrieving, and
managing data in memory and on disk, designed to capture a persistent, long term
memory of each node. While databases can respond to
complex queries, storage engines look at the data more granularly and offer a
simple data manipulation API, allowing users to create, update, delete, and
retrieve records. One way to look at this is that database management systems
are applications built on top of storage engines, offering a **schema**, a **query
language**, **indexing**, **transactions**, and many other useful features.

- - -

The more knowledge you have about the database before using it, the
more time you’ll save when running it in production.

- - -

Online transaction processing (**OLTP**) databases

- These handle a large number of user-facing requests and transactions.

- Queries are often predefined and short-lived.

Online analytical processing (**OLAP**) databases

- These handle complex aggregations.

- OLAP databases are often used for analytics and data warehousing, and are capable of handling complex, long-running ad hoc queries.

Hybrid transactional and analytical processing (**HTAP**)

- These databases combine properties of both OLTP and OLAP stores.

- - -

**DBMS Architecture**

![Figure 1-1. Architecture of a database management system](/assets/alex-petrov-database-internals/figure 1-1. architecture of a database management system.png)

- - -

**Column- Versus Row-Oriented DBMS**

Most database systems store a set of data records, consisting of **columns** and
**rows** in tables. **Field** is an intersection of a column and a row: a single value
of some type. Fields belonging to the same column usually have the same
data type. A collection of values that belong logically to the same record (usually identified by the key)
constitutes a **row**.

One of the ways to classify databases is by how the data is stored on disk:
row- or column-wise. Tables can be partitioned either horizontally (storing
values belonging to the same row together), or vertically (storing values
belonging to the same column together).

![Figure 1-2. Data layout in column- and row-oriented stores](/assets/alex-petrov-database-internals/figure 1-2. data layout in column- and row-oriented stores.png)

**Row-Oriented Data Layout**

Row-oriented database management systems store data in records or rows.
Their layout is quite close to the tabular data representation, where every row
has the same set of fields.

```none
| ID | Name | Birth Date | Phone Number |
| 10 | John | 01 Aug 1981 | +1 111 222 333 |
| 20 | Sam | 14 Sep 1988 | +1 555 888 999 |
| 30 | Keith | 07 Jan 1984 | +1 333 444 555 |
```

This approach works well for cases where several fields constitute the record
(name, birth date, and a phone number) uniquely identified by the key (in this
example, a monotonically incremented number). All fields representing a
single user record are often read together. When creating records (for
example, when the user fills out a registration form), we write them together
as well. At the same time, each field can be modified individually.

Since **row-oriented stores are most useful in scenarios when we have to
access data by row, storing entire rows together** improves **spatial locality**.

Because data on a persistent medium such as a disk is typically accessed
block-wise (in other words, a minimal unit of disk access is a block), a single
block will contain data for all columns. This is great for cases when we’d like
to access an entire user record, but makes queries accessing individual fields
of multiple user records (for example, queries fetching only the phone
numbers) more expensive, since data for the other fields will be paged in as
well.

**Column-Oriented Data Layout**

Column-oriented database management systems partition data vertically (i.e.,
by column) instead of storing it in rows. Here, values for the same column
are stored contiguously on disk (as opposed to storing rows contiguously as
in the previous example).

**Storing values for different columns
in separate files or file segments allows efficient queries by column, since
they can be read in one pass rather than consuming entire rows and
discarding data for columns that weren’t queried.**

Column-oriented stores are a good fit for analytical workloads that compute
aggregates, such as finding trends, computing average values, etc.

From a logical perspective, the data representing stock market price quotes
can still be expressed as a table:

```none
| ID | Symbol | Date | Price |
| 1 | DOW | 08 Aug 2018 | 24,314.65 |
| 2 | DOW | 09 Aug 2018 | 24,136.16 |
| 3 | S&P | 08 Aug 2018 | 2,414.45 |
| 4 | S&P | 09 Aug 2018 | 2,232.32 |
```

However, the physical column-based database layout looks entirely different.
Values belonging to the same row are stored closely together:

```none
Symbol: 1:DOW; 2:DOW; 3:S&P; 4:S&P
Date:   1:08 Aug 2018; 2:09 Aug 2018; 3:08 Aug 2018; 4:09 Aug 2018
Price:  1:24,314.65; 2:24,136.16; 3:2,414.45; 4:2,232.32
```

To reconstruct data tuples, which might be useful for joins, filtering, and
multirow aggregates, we need to preserve some metadata on the column level
to identify which data points from other columns it is associated with. If you
do this explicitly, each value will have to hold a key, which introduces
duplication and increases the amount of stored data. Some column stores use
implicit identifiers (virtual IDs) instead and use the position of the value (in
other words, its offset) to map it back to the related values.

**Distinctions and Optimizations**

It is not sufficient to say that distinctions between row and column stores are
only in the way the data is stored. Choosing the data layout is just one of the
steps in a series of possible optimizations that columnar stores are targeting.

Reading multiple values for the same column in one run significantly
improves **cache** utilization and **computational** efficiency. On modern CPUs,
**vectorized instructions** can be used to process multiple data points with a
single CPU instruction.

Storing values that have the same data type together (e.g., numbers with other
numbers, strings with other strings) offers a better **compression** ratio. We can
use different compression algorithms depending on the data type and pick the
most effective compression method for each case.

To decide whether to use a column- or a row-oriented store, you need to
understand your ***access patterns***. If the read data is consumed in records (i.e.,
most or all of the columns are requested) and the workload consists mostly of
point queries and range scans, the row-oriented approach is likely to yield
better results. If scans span many rows, or compute aggregate over a subset of
columns, it is worth considering a column-oriented approach.

**Wide Column Stores**

Column-oriented databases should not be mixed up with **wide column stores**,
such as `BigTable` or `HBase`, where data is represented as a multidimensional
map, columns are grouped into **column families** (usually storing data of the
same type), and inside each column family, data is stored row-wise.


