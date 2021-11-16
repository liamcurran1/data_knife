# Data Knife

# Project Documentation

This project is aimed at providing a full web application for carrying
out data management tasks associated with curating and building datasets
for analysis. It consists of four components which together will make
up the full web application. However, it is being released in stages
according to the following timescale.

1.  sql - PostgreSQL procedures and functions: November 2021
2.  docs - Documentation on the full web application: December 2021
3.  python and html - Web application Python and HTML templates: January
    2022

It is being released in stages to allow people to use the *sql*
components if they already have an application that they use to access
their data repository and they just need something that will index data
to use with that application. The full web based application will follow
soon.

Here are the current sections of this document:

  - Project Description
  - Prerequisites

## Project Description

Data science projects often involve the linkage and analysis of data
drawn from tens or even hundreds of data sources. Often these data
sources are available in CSV or other file format and a significant
proportion of the effort in any analysis project goes into the data
management required to organise and link related data sources to product
specific datasets. This is a common problem in *Machine Learning*
projects.

Using relational databases, like PostgreSQL, to store such disparate
data sources is a major help in simplifying the complexity of the data
management process, but there still remains the substantial task of
selecting subsets of data drawn from across all the data sources and
generating bespoke datasets for specific analyses. This is the problem
that *Data Knife* is designed to address. It also provides a permanent
record of every such subset of the data generated, stored as named
lists. These lists are useful for audit purposes and to enable the
reproducibility of scientific results, without having to permanently
archive copies of all files generated. *Data Knife* can help you produce
subsets of data drawn from tens or hundreds of tables in a PostgreSQL
database. The data from a selected subset are output to a CSV file ready
to be loaded into R, Tensorflow, or any other analysis package of
choice.

## Prerequisites

In order to link disparate data from many PostgreSQL tables there must
be **at least one unique identifier for all data subjects in each
table** indexed by *Data Knife*. A PostgreSQL database must be created
to hold the data tables and the data should be stored in schemas other
than the *public* schema. For example a database holding data on UK
regional income data could be organised like this:

    database: regional_income
        |
        |___schema: london
        |      |
        |      |___table: total_income
        |      |___table: perhead_income
        |
        |___schema: north_east
        |      |
        |      |___table: total_income
        |      |___table: perhead_income
        ...

The important point here is that the *public* schema is used to store
data for *Data Knife* and to act as a staging area for general data
management tasks. **Tables in the *public* schema are not indexed by
*Data Knife*.**

Field names within all tables must be unique across all schemas except
for identifiers. This may involve some processing before tables are
deployed to indexed schemas and is typically a process which takes place
in the *public* schema.

## Installation Instructions

### PostgreSQL

Version 12 of PostgreSQL was used to develop Data Knife, but it has been
tried on version 9.3 and there is a high probability that it will work
on anything after 9.3.

Any secure method should be used to read the sql components into the
database to be indexed.

The typical sequence of actions to enable the output of CSV files from
your indexed data is as follows:

1.  Run the indexing SQL procedure *build\_index*
2.  Create lists of fields/variables using the SQL procedures
    *put\_list\_write* and *put\_list\_desc*
3.  Choose a list to build as a dataset
4.  Run the SQL procedure *data\_write* to create a CSV file

#### Running the SQL indexing procedure *build\_index*

``` sql
CALL build_index();
```

#### Create a list of fields/variables

The following procedures can be used to manually or programmatically
build a stored list of field names that have been indexed by *Data
Knife*.

Note that list names must be unique, as they are used to identify
subsets of data indexed by *Data Knife*. These lists can then be
subsequently selected to build datasets.

Call the following SQL procedure once for every field that is a member
of the new list:

``` sql
CALL put_list_field('<list_name>', '<field_name>');
```

Then call the following procedure to add a descriptive label for the
list named *<list_name>*.

``` sql
CALL put_list_desc('<list_name>', '<description>');
```

#### Running the SQL procedure *data\_write*

Choose a file name and path to write the output CSV file to. Note that
this path must be one where the user running the PostgreSQL service has
write permissions. On Linux systems choosing a file in /tmp should work.

``` sql
CALL data_write('<file path>');
```
