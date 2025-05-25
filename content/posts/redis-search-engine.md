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

[Countinue learning](https://university.redis.io/course/kfqi66sxurbqua?tab=details)
