---
date: '2025-05-25T11:33:00+07:00'
draft: true
title: 'Redis Search Engine: A Comprehensive Guide'
tags: ['Redis', 'Search Engine', 'Notes']
references:
  - title: 'Redis Search Engine Course'
    url: 'https://university.redis.io/learningpath/pdkbr7xdv3miym?tab=details'
  - title: 'Redis Documentation'
    url: 'https://redis.io/docs/latest/develop/interact/search-and-query/'
---

For better understanding the commands and examples in this post, please follow the instuctions in the [GitHub Repository](https://github.com/redislabs-training/ru-rqe) to set up the environment.

The data model used in this post

{{< mermaid >}}
erDiagram
    Authors {
        varchar name
        int author_id PK
    }

    Books {
        varchar isbn PK
        varchar title
        varchar subtitle
        varchar thumbnail
        text description
        varchar categories
        varchar authors
        json author_ids
    }

    Users {
        varchar first_name
        varchar last_name
        varchar email
        int user_id PK
        datetime last_login
    }

    Author_Books {
        int author_id PK,FK
        varchar book_isbn PK,FK
    }

    Checkouts {
        int user_id PK,FK
        varchar book_isbn PK,FK
        date checkout_date
        int checkout_length_days
        varchar geopoint
    }

    Authors ||--o{ Author_Books : "has"
    Books ||--o{ Author_Books : "is written by"
    Users ||--o{ Checkouts : "makes"
    Books ||--o{ Checkouts : "is checked out"
{{< /mermaid >}}

```bash
FT.CREATE books-idx 
    ON HASH PREFIX 1 ru203:book:details: 
    SCHEMA 
        isbn TAG SORTABLE 
        title TEXT WEIGHT 2.0 SORTABLE 
        subtitle TEXT SORTABLE 
        thumbnail TAG NOINDEX 
        description TEXT SORTABLE 
        published_year NUMERIC SORTABLE 
        average_rating NUMERIC SORTABLE 
        authors TEXT SORTABLE 
        categories TAG SEPARATOR ";" 
        author_ids TAG SEPARATOR ";"
```

## Querying structured data with Redis Query Engine

`TAG` is the most efficient field type for exact string matches.

```bash
FT.SEARCH books-idx "@isbn:{9780393059168}"
FT.SEARCH books-idx "@author_ids:{690}" RETURN 1 title"
```

Escape special characters in the query string using a backslash (`\`):
`,.<>{}[]"':;!@#$%^&*()-+=~`

```bash
FT.SEARCH books-idx "@authors:{j\\. r\\. r\\. tolkien}"
```

`NUMERIC` is used for numeric fields, allowing range queries.

The range syntax is `[min max]`, where `min` and `max` can be `-inf` or `+inf` for unbounded ranges. This range is inclusive of both endpoints. To exclude an endpoint, add `(` before the value.

```bash
FT.SEARCH books-idx "@average_rating:[4.5 5.0]" RETURN 1 title
FT.SEARCH books-idx "@average_rating:[4 +inf] @published_year:[2015 +inf]" RETURN 1 title
FT.SEARCH books-idx "@average_rating:[-inf 3] @published_year:[-inf (2000]" RETURN 1 title
FT.SEARCH books-idx "@average_rating:[4.5 5.0] @published_year:[(2015 +inf]" RETURN 1 title
```

Queries which dont use a specific field will default to full-text search using all `TEXT` fields.

```bash
FT.SEARCH books-idx "dogs|cats"
FT.SEARCH books-idx "dogs -cats" RETURN 1 title
FT.SEARCH books-idx "@authors:'rowling' @title:'goblet'"
FT.SEARCH books-idx "@authors:\"rowling\" | @title:\"potter\""
FT.SEARCH books-idx "@authors:tolkien -@title:ring"
FT.SEARCH books-idx “@categories:{Philosophy} @published_year:[-inf 1975] -@authors:'Arthur Koestler'”
FT.SEARCH books-idx "@authors:'Arthur Koestler' | @authors:'Michel Foucault'"
```

#### What is the difference between `TEXT` and `TAG`, when to use which?

[TBU]

`SORTABLE` is used for sorting results based on a specific field. It can be used with `NUMERIC`, `TEXT`, or `TAG` fields. This only allows short by only one field at a time.

```bash
FT.CREATE books-idx 
  ON HASH PREFIX 1 ru203:book:details: 
  SCHEMA 
    ...
    published_year NUMERIC SORTABLE 
    ...

FT.SEARCH books-idx "@published_year:[2018 +inf]" SORTBY published_year DESC
```

#### What if I using `SORTBY` on a field that is not add `SORTABLE` keyword in the schema?

[TBU] No error

`LIMIT` is used to limit the number of results returned by a query. This takes two arguments: the zero-based offset and the count.

```bash
FT.SEARCH books-idx "@authors:Agatha Christie" SORTBY published_year LIMIT 0 5
```

## Full-text search with Redis Query Engine

When a field is defined as `TEXT`, RedisSearch store the root form of the word, not the exact word. For example, the word "running" will be stored as "run", and the word "dogs" will be stored as "dog". This is called `stemming`. Stemming is used to improve search results by matching different forms of a word.

```bash {linenos=false}
> FT.SEARCH books-idx "@title:running" RETURN 1 title
1) "14"
2) "ru203:book:details:9780451197962"
3) 1) "title"
   2) "The Running Man"
4) "ru203:book:details:9780385315289"
5) 1) "title"
   2) "Running from Safety"
6) "ru203:book:details:9780679722946"
7) 1) "title"
   2) "Running Dog"
8) "ru203:book:details:9780345461612"
9) 1) "title"
   2) "Running from the Deity"
10) "ru203:book:details:9780330281720"
11) 1) "title"
   2) "Running in the Family"
12) "ru203:book:details:9780590317672"
13) 1) "title"
   2) "Run"
14) "ru203:book:details:9780439650366"
15) 1) "title"
   2) "Werewolves Don't Run For President"
16) "ru203:book:details:9781400033829"
17) 1) "title"
   2) "Who Will Run the Frog Hospital?"
18) "ru203:book:details:9780340769201"
19) 1) "title"
   2) "Running Away from Richard"
20) "ru203:book:details:9780671024185"
21) 1) "title"
   2) "Morgan's Run"
```

The RedisSearch also supports `prefix` search, which allows you to search for words that start with a specific prefix. *Note that the less specific the query, the more worse the performance.*

```bash
FT.SEARCH books-idx "atwood hand*"
FT.SEARCH books-idx "agat* orie*"
```

`SUMMARY` is used to summarize the search results. This is useful for displaying a brief description of the search results. The `SUMMARY` will returns first `LEN` characters of the field, and the `FRAGS` will return the number of fragments to return. The `FIELDS` option is used to specify which fields to summarize.

```bash
FT.SEARCH books-idx agamemnon SUMMARIZE FIELDS 1 description FRAGS 3 LEN 25
```

`HIGHLIGHT` is used to highlight the search terms in the results. This is useful for displaying the search results in a user-friendly way.

```bash
FT.SEARCH books-idx agamemnon SUMMARIZE FIELDS 1 description FRAGS 3 LEN 25 HIGHLIGHT
FT.SEARCH books-idx agamemnon SUMMARIZE FIELDS 1 description FRAGS 3 LEN 25 HIGHLIGHT FIELDS 1 description
```

## Aggregation with Redis Query Engine

Aggregation is used to perform calculations on the data, such as counting, summing, or averaging, which is useful for analyzing large datasets. The `FT.AGGREGATE` command is used to perform aggregation queries.

`COUNT` is used to count the number of records that match a specific query.

```bash
FT.SEARCH books-idx * LIMIT 0 0
FT.AGGREGATE books-idx * GROUPBY 0 REDUCE COUNT 0 AS total
```

`GROUPBY` is used to group the results by a specific field.

```bash
FT.AGGREGATE books-idx * GROUPBY 1 @authors REDUCE COUNT 0 as published_books
FT.AGGREGATE books-idx marauder GROUPBY 2 @published_year @average_rating
```

`REDUCE` is used to perform calculations on the grouped results. Some common reduce functions are `COUNT`, `COUNT_DISTINCTISH`, `SUM`, `AVG`, `MIN`, and `MAX`.

```bash
FT.AGGREGATE books-idx * GROUPBY 1 @categories REDUCE COUNT 0 as total SORTBY 2 @total DESC
FT.AGGREGATE books-idx tolkien GROUPBY 0 REDUCE AVG 1 @average_rating as avg_rating
```

`APPLY` is used to apply a custom function to the results. This is useful for performing complex calculations that are not supported by the built-in reduce functions.

```bash
FT.AGGREGATE books-idx * 
   APPLY "split(@authors, ';')" AS authors_list 
   GROUPBY 1 @title 
   REDUCE COUNT_DISTINCT 1 authors_list AS authors_count 
   FILTER "@authors_count==2"

FT.AGGREGATE users-idx * 
   GROUPBY 2 @last_login @user_id 
   APPLY "dayofweek(@last_login)" AS day_of_week 
   GROUPBY 1 @day_of_week 
   REDUCE COUNT 0 AS login_count 
   SORTBY 1 @day_of_week
```
