---
layout: post
title: Designing Data-Intensive Applications
date: 2021-02-11 16:42:53 +0800
categories: ['Data']
tags: ['Data']
---

Reliability:
    Hardware Faults
    Software Errors
    Human Errors

Scalability:
   Load Parameters
        request per second to a web server
        ratio of reads and writes in a database
    Performance
        throughput
        response time

        ***Latency** and **response time** are often used synonymously, but they are not the same. The response time is what the client sees: besides the actual time to process the request (the service time), it includes network delays and queueing delays. Latency is the duration that a request is waiting to be handled—during which it is latent, await‐ ing service.*

        average response time
        percentile
        median
        p50 p99 p999 p9999
        service level objectives (SLOs)
        service level agreements (SLAs)
        tail latencies
        head-of-line blocking
        tail latency amplification


online transaction processing (OLTP)

    Even though databases started being used for many different kinds of data—com‐ ments on blog posts, actions in a game, contacts in an address book, etc.—the basic access pattern remained similar to processing business transactions. An application typically looks up a small number of records by some key, using an index. Records are inserted or updated based on the user’s input. Because these applications are interactive, the access pattern became known as online transaction processing (OLTP).

online analytic processing (OLAP)

    However, databases also started being increasingly used for **data analytics**, which has very different access patterns. Usually an analytic query needs to scan over a huge number of records, only reading a few columns per record, and calculates aggregate statistics (such as count, sum, or average) rather than returning the raw data to the user. 

    These queries are often written by **business analysts**, and feed into reports that help the management of a company make better decisions (**business intelligence**). In order to differentiate this pattern of using databases from transaction processing, it has been called online analytic processing (OLAP) [47].

data warehouse

    At first, the same databases were used for both transaction processing and analytic queries. SQL turned out to be quite flexible in this regard: it works well for OLTP- type queries as well as OLAP-type queries. Nevertheless, in the late 1980s and early 1990s, there was a trend for companies to stop using their OLTP systems for analytics purposes, and to run the analytics on a separate database instead. This separate data‐ base was called a **data warehouse**.

    A **data warehouse**, by contrast, is a separate database that analysts can query to their hearts’ content, without affecting OLTP operations [48]. The data warehouse con‐ tains a read-only copy of the data in all the various OLTP systems in the company. Data is extracted from OLTP databases (using either a periodic data dump or a con‐ tinuous stream of updates), transformed into an analysis-friendly schema, cleaned up, and then loaded into the data warehouse. This process of getting data into the warehouse is known as **Extract–ransform–oad (ETL)** and is illustrated in Figure 3-8.

- - -

Stars and Snowflakes: Schemas for Analytics

Many data warehouses are used in a fairly formulaic style, known as a star schema (also known as dimen‐ sional modeling [55]).

The example schema in Figure 3-9 shows a data warehouse that might be found at a grocery retailer. At the center of the schema is a so-called **fact table** (in this example, it is called **fact\_sales**). Each row of the fact table represents an event that occurred at a particular time (here, each row represents a customer’s purchase of a product). If we were analyzing website traffic rather than retail sales, each row might represent a page view or a click by a user.

Some of the columns in the fact table are **attributes**, such as the price at which the product was sold and the cost of buying it from the supplier (allowing the profit margin to be calculated). Other columns in the fact table are **foreign key** references to other tables, called **dimension tables**. **As each row in the fact table represents an event, the dimensions represent the who, what, where, when, how, and why of the event.**

The name “star schema” comes from the fact that when the table relationships are visualized, the fact table is in the middle, surrounded by its dimension tables; the connections to these tables are like the rays of a star.

A variation of this template is known as the snowflake schema, where dimensions are further broken down into subdimensions. For example, there could be separate tables for brands and product categories, and each row in the dim\_product table could ref‐ erence the brand and category as foreign keys, rather than storing them as strings in the dim\_product table. Snowflake schemas are more normalized than star schemas, but star schemas are often preferred because they are simpler for analysts to work with [55].

In a typical data warehouse, tables are often very wide: fact tables often have over 100 columns, sometimes several hundred [51]. Dimension tables can also be very wide, as they include all the metadata that may be relevant for analysis—for example, the dim\_store table may include details of which services are offered at each store, whether it has an in-store bakery, the square footage, the date when the store was first opened, when it was last remodeled, how far it is from the nearest highway, etc.

Column-Oriented Storage

    The idea behind column-oriented storage is simple: don’t store all the values from one row together, but store all the values from each column together instead. If each column is stored in a separate file, a query only needs to read and parse those columns that are used in that query, which can save a lot of work.

Aggregation: Data Cubes and Materialized Views

Another aspect of data warehouses that is worth mentioning briefly is **materialized aggregates**. As discussed earlier, data warehouse queries often involve an aggregate function, such as COUNT, SUM, AVG, MIN, or MAX in SQL. If the same aggregates are used by many different queries, it can be wasteful to crunch through the raw data every time. Why not cache some of the counts or sums that queries use most often?

One way of creating such a cache is a **materialized view**. In a relational data model, it is often defined like a standard (virtual) view: a table-like object whose contents are the results of some query. The difference is that a materialized view is an actual copy of the query results, written to disk, whereas a virtual view is just a shortcut for writing queries. When you read from a virtual view, the SQL engine expands it into the view's underlying query on the fly and then processes the expanded query.

A common special case of a materialized view is known as a data cube or OLAP cube [64]. It is a grid of aggregates grouped by different dimensions. 

The advantage of a materialized data cube is that certain queries become very fast because they have effectively been **precomputed**. 

**OLTP vs OLAP**

On a high level, we saw that storage engines fall into two broad categories: those opti‐ mized for transaction processing (OLTP), and those optimized for analytics (OLAP). There are big differences between the access patterns in those use cases:

    OLTP systems are typically user-facing, which means that they may see a huge volume of requests. In order to handle the load, applications usually only touch a small number of records in each query. The application requests records using some kind of key, and the storage engine uses an index to find the data for the requested key. Disk seek time is often the bottleneck here.

    Data warehouses and similar analytic systems are less well known, because they are primarily used by business analysts, not by end users. They handle a much lower volume of queries than OLTP systems, but each query is typically very demanding, requiring many millions of records to be scanned in a short time. Disk bandwidth (not seek time) is often the bottleneck here, and column- oriented storage is an increasingly popular solution for this kind of workload.


Everything changes and nothing stands still.
—Heraclitus of Ephesus, as quoted by Plato in Cratylus (360 BCE)

Backward compatibility

    Newer code can read data that was written by older code.

Forward compatibility

    Older code can read data that was written by newer code.

Formats for Encoding Data

Programs usually work with data in (at least) two different representations:

  1. In memory, data is kept in objects, structs, lists, arrays, hash tables, trees, and so on. These data structures are optimized for efficient access and manipulation by the CPU (typically using pointers).

  2. When you want to write data to a file or send it over the network, you have to encode it as some kind of self-contained sequence of bytes (for example, a JSON document). Since a pointer wouldn’t make sense to any other process, this sequence-of-bytes representation looks quite different from the data structures that are normally used in memory.

Thus, we need some kind of translation between the two representations. The translation from the in-memory representation to a byte sequence is called **encoding** (also known as serialization or marshalling), and the reverse is called **decoding** (parsing, deserialization, unmarshalling).
