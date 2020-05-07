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
single CPU instruction (**SIMD**).

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

- - -

**Data Files and Index Files**

The primary goal of a database system is to store data and to allow quick
access to it.

Database systems do use files for storing the data, but instead of relying on
filesystem hierarchies of directories and files for locating records, they
compose files using implementation-specific formats. 

Database systems store **data records**, consisting of multiple fields, in tables,
where each table is usually represented as a separate file. Each record in the
table can be looked up using a **search key**. To locate a record, database
systems use **indexes**: auxiliary data structures that allow it to efficiently locate
data records without scanning an entire table on every access. Indexes are
built using a subset of fields identifying the record.

A database system usually separates **data files** and **index files**: data files store
data records, while index files store record metadata and use it to locate
records in data files. Index files are typically smaller than the data files. Files
are partitioned into **pages**, which typically have the size of a single or
multiple disk blocks. Pages can be organized as sequences of records or as a
**slotted pages**.

New records (insertions) and updates to the existing records are represented
by key/value pairs. Most modern storage systems do not delete data from
pages explicitly. Instead, they use **deletion markers** (also called **tombstones**),
which contain deletion metadata, such as a key and a timestamp. Space
occupied by the records **shadowed** by their updates or deletion markers is
reclaimed during garbage collection, which reads the pages, writes the live
(i.e., nonshadowed) records to the new place, and discards the shadowed
ones.

**Data Files**

Data files (sometimes called **primary files**) can be implemented as **index-organized
tables** (IOT), **heap-organized tables** (heap files), or **hash-organized
tables** (hashed files).

Records in heap files are not required to follow any particular order, and most
of the time they are placed in a write order. This way, no additional work or
file reorganization is required when new pages are appended. Heap files
require additional index structures, pointing to the locations where data
records are stored, to make them searchable.

In hashed files, records are stored in buckets, and the hash value of the key
determines which bucket a record belongs to. Records in the bucket can be
stored in append order or sorted by key to improve lookup speed.

Index-organized tables (IOTs) store data records in the index itself. Since
records are stored in key order, range scans in IOTs can be implemented by
sequentially scanning its contents.

Storing data records in the index allows us to reduce the number of disk seeks
by at least one, since after traversing the index and locating the searched key,
we do not have to address a separate file to find the associated data record.

When records are stored in a separate file, index files hold data entries,
uniquely identifying data records and containing enough information to
locate them in the data file. For example, we can store file **offsets** (sometimes
called **row locators**), locations of data records in the data file, or bucket IDs
in the case of hash files. In index-organized tables, data entries hold actual
data records.

**Index Files**

An index is a structure that organizes data records on disk in a way that
facilitates efficient retrieval operations. Index files are organized as
specialized structures that map keys to locations in data files where the
records identified by these keys (in the case of heap files) or primary keys (in
the case of index-organized tables) are stored.

An index on a **primary** (data) file is called the **primary index**. However, in
most cases we can also assume that the primary index is built over a primary
key or a set of keys identified as primary. All other indexes are called
**secondary**.

Secondary indexes can point directly to the data record, or simply store its
primary key. A pointer to a data record can hold an offset to a heap file or an
index-organized table. Multiple secondary indexes can point to the same
record, allowing a single data record to be identified by different fields and
located through different indexes. While primary index files hold a unique
entry per search key, secondary indexes may hold several entries per search
key.

If the order of data records follows the search key order, this index is called
**clustered** (also known as clustering). Data records in the clustered case are
usually stored in the same file or in a **clustered** file, where the key order is
preserved. If the data is stored in a separate file, and its order does not follow
the key order, the index is called **nonclustered** (sometimes called
unclustered).

![Figure 1-5. Storing data records in an index file versus storing offsets to the data file](/assets/alex-petrov-database-internals/figure 1-5. storing data records in an index file versus storing offsets to the data file.png)

NOTE: Index-organized tables store information in index order and are clustered by definition.
Primary indexes are most often clustered. Secondary indexes are nonclustered by
definition, since they’re used to facilitate access by keys other than the primary one.
Clustered indexes can be both index-organized or have separate index and data files.

**Primary Index as an Indirection**

By referencing data directly, we can
reduce the number of disk seeks, but have to pay a cost of updating the
pointers whenever the record is updated or relocated during a maintenance
process. Using indirection in the form of a primary index allows us to reduce
the cost of pointer updates, but has a higher cost on a read path.

Updating just a couple of indexes might work if the workload mostly consists
of reads, but this approach does not work well for write-heavy workloads
with multiple indexes. To reduce the costs of pointer updates, instead of
payload offsets, some implementations use primary keys for indirection.

![](/assets/alex-petrov-database-internals/figure 1-6. referencing data tuples directly versus using a primary index as indirection.png)

It is also possible to use a hybrid approach and store both data file offsets and
primary keys. First, you check if the data offset is still valid and pay the extra
cost of going through the primary key index if it has changed, updating the
index file after finding a new offset.

**Buffering, Immutability, and Ordering**

Storage structures have three common variables: they use **buffering** (or avoid
using it), use **immutable** (or mutable) files, and store values **in order** (or out
of order). Most of the distinctions and optimizations in storage structures
discussed are related to one of these three concepts.

**Buffering**

This defines whether or not the storage structure chooses to collect a
certain amount of data in memory before putting it on disk. Of course,
every on-disk structure has to use buffering to some degree, since the
smallest unit of data transfer to and from the disk is a block, and it is
desirable to write full blocks.

**Mutability (or immutability)**

This defines whether or not the storage structure reads parts of the file,
updates them, and writes the updated results at the same location in the
file. Immutable structures are append-only: once written, file contents are
not modified. Instead, modifications are appended to the end of the file.
There are other ways to implement immutability. One of them is **copy-on-write**
, where the modified page, holding the
updated version of the record, is written to the new location in the file,
instead of its original location. Often the distinction between LSM and B-Trees
is drawn as immutable against in-place update storage, but there are
structures (for example, Bw-Trees) that are inspired by B-Trees but are
immutable.

**Ordering**

This is defined as whether or not the data records are stored in the key
order in the pages on disk. In other words, the keys that sort closely are
stored in contiguous segments on disk. Ordering often defines whether or
not we can efficiently scan the range of records, not only locate the
individual data records. Storing data out of order (most often, in insertion
order) opens up for some write-time optimizations.

- - -
