---
date: '2025-05-27T11:24:00+07:00'
draft: false
title: 'Redis University: Redis Search Engine'
tags: ['redis', 'search-engine', 'notes']
cover:
    image: 'images/redis_search_engine_notes/cover.png'
references:
  - title: 'Redis Search Engine Course'
    url: 'https://university.redis.io/learningpath/pdkbr7xdv3miym?tab=details'
  - title: 'Redis Documentation'
    url: 'https://redis.io/docs/latest/develop/interact/search-and-query/'
---

This post is my personal notes on the Redis Search Engine course from [Redis University](https://university.redis.io/learningpath/pdkbr7xdv3miym?tab=details). It covers the basics of the Redis Query Engine, including how to create indexes, perform queries, and use advanced features like aggregation and spellcheck.

To make the most of the commands and examples in this post, set up your Redis environment and load the data by following the instructions in the [GitHub Repository](https://github.com/redislabs-training/ru-rqe). Once set up, create the index by running the following command in the Redis CLI:

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

## Querying Structured Data with Redis Query Engine

### Exact Matches with `TAG`

The `TAG` field type is ideal for exact string matches, offering high efficiency.

```bash
FT.SEARCH books-idx "@isbn:{9780393059168}"
FT.SEARCH books-idx "@author_ids:{690}" RETURN 1 title
```

To query strings containing special characters (`,.<>{}[]"':;!@#$%^&*()-+=~`), escape them with a backslash (`\`).

```bash
FT.SEARCH books-idx "@authors:{j\\. r\\. r\\. tolkien}"
```

### Numeric Range Queries with `NUMERIC`

Use the `NUMERIC` field type for numerical data, enabling powerful range queries. The range syntax is `[min max]`, inclusive of both endpoints. Use `-inf` or `+inf` for unbounded ranges. To exclude an endpoint, add `(` before the value.

```bash
FT.SEARCH books-idx "@average_rating:[4.5 5.0]" RETURN 1 title
FT.SEARCH books-idx "@average_rating:[4 +inf] @published_year:[2015 +inf]" RETURN 1 title
FT.SEARCH books-idx "@average_rating:[-inf 3] @published_year:[-inf (2000]" RETURN 1 title
FT.SEARCH books-idx "@average_rating:[4.5 5.0] @published_year:[(2015 +inf]" RETURN 1 title
```

### Full-Text Search with `TEXT`

Queries without a specified field default to full-text search across all `TEXT` fields.

```bash
FT.SEARCH books-idx "dogs|cats"
FT.SEARCH books-idx "dogs -cats" RETURN 1 title
FT.SEARCH books-idx "@authors:'rowling' @title:'goblet'"
FT.SEARCH books-idx "@authors:\"rowling\" | @title:\"potter\""
FT.SEARCH books-idx "@authors:tolkien -@title:ring"
FT.SEARCH books-idx “@categories:{Philosophy} @published_year:[-inf 1975] -@authors:'Arthur Koestler'”
FT.SEARCH books-idx "@authors:'Arthur Koestler' | @authors:'Michel Foucault'"
```

> `TEXT` vs. `TAG`: `TEXT` fields undergo stemming (e.g., "running" becomes "run"), allowing broader matches. `TAG` fields provide exact string matches without stemming.

### Sorting Results with `SORTABLE`

The `SORTABLE` option allows you to sort query results by a specified field (`NUMERIC`, `TEXT`, or `TAG`). Note that sorting is limited to one field at a time.

```bash
FT.CREATE books-idx 
  ON HASH PREFIX 1 ru203:book:details: 
  SCHEMA 
    ...
    published_year NUMERIC SORTABLE 
    ...

FT.SEARCH books-idx "@published_year:[2018 +inf]" SORTBY published_year DESC
```

> Using `SORTBY` on a field not marked SORTABLE will cause an error.

### Limiting Results with `LIMIT`

`LIMIT` controls the number of results returned, taking a zero-based offset and a count.

```bash
FT.SEARCH books-idx "@authors:Agatha Christie" SORTBY published_year LIMIT 0 5
```

## Full-text search with Redis Query Engine

### Stemming

`TEXT` fields in RedisSearch store the root form of words (stemming), improving search results by matching different word forms (e.g., "running" matches "run").

```bash {linenos=false}
> FT.SEARCH books-idx "@title:running" RETURN 1 title
1) "14"
2) "ru203:book:details:9780451197962"
3) 1) "title"
   2) "The Running Man"
4) "ru203:book:details:9780385315289"
5) 1) "title"
   2: "Running from Safety"
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

### Prefix Search

Prefix search finds words starting with a specific prefix. 

> Be aware that less specific queries can impact performance.

```bash
FT.SEARCH books-idx "atwood hand*"
FT.SEARCH books-idx "agat* orie*"
```

### Summarizing and Highlighting Results

`SUMMARIZE` provides a brief description of search results, returning the first `LEN` characters and `FRAGS` (number of fragments) from specified `FIELDS`.

```bash
FT.SEARCH books-idx agamemnon SUMMARIZE FIELDS 1 description FRAGS 3 LEN 25
```

`HIGHLIGHT` emphasizes search terms within results for better readability.

```bash
FT.SEARCH books-idx agamemnon SUMMARIZE FIELDS 1 description FRAGS 3 LEN 25 HIGHLIGHT
FT.SEARCH books-idx agamemnon SUMMARIZE FIELDS 1 description FRAGS 3 LEN 25 HIGHLIGHT FIELDS 1 description
```

## Aggregation with Redis Query Engine

The `FT.AGGREGATE` command performs calculations like counting, summing, or averaging on data, useful for large datasets.

### Counting Results with `COUNT`

`COUNT` is used to count the number of records that match a specific query.

```bash
FT.SEARCH books-idx * LIMIT 0 0
FT.AGGREGATE books-idx * GROUPBY 0 REDUCE COUNT 0 AS total
```

### Grouping Data with `GROUPBY`

`GROUPBY` is used to group the results by a specific field.

```bash
FT.AGGREGATE books-idx * GROUPBY 1 @authors REDUCE COUNT 0 as published_books
FT.AGGREGATE books-idx marauder GROUPBY 2 @published_year @average_rating
```

### Performing Calculations with `REDUCE`

`REDUCE` executes calculations on grouped results. Common functions include `COUNT`, `COUNT_DISTINCTISH`, `SUM`, `AVG`, `MIN`, and `MAX`.

```bash
FT.AGGREGATE books-idx * GROUPBY 1 @categories REDUCE COUNT 0 as total SORTBY 2 @total DESC
FT.AGGREGATE books-idx tolkien GROUPBY 0 REDUCE AVG 1 @average_rating as avg_rating
```

### Applying Custom Functions with `APPLY`

`APPLY` allows custom functions for complex calculations not supported by built-in reduce functions.

```bash
FT.AGGREGATE books-idx *
   APPLY "split(@authors, ';')" AS authors_list
   GROUPBY 1 @title
   REDUCE COUNT_DISTINCT 1 authors_list AS authors_count
   FILTER "@authors_count==2"
```

## Advanced Redis Query Engine Topics

### Partial Indexing

Partial indexing indexes only a subset of fields, useful for large documents where only specific fields require searching.

```bash
FT.CREATE books-older-idx 
   ON HASH PREFIX 1 ru203:book:details: 
   FILTER "@published_year<1990" 
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

### Adjusting Result Scores with `WEIGHT`

The `WEIGHT` option allows you to adjust the score of results, boosting the relevance of certain fields.

```bash
FT.SEARCH books-idx "((@categories:{History}) => { $weight: 10 } greek) | greek" RETURN 2 title categories
```

### Handling Punctuation in Fields

If you wanna do matching on a field that contains punctiation, you need to proccess this field by escaping the punctuation characters.

```bash
HMSET ru203:user:details:1000 
   first_name "Andrew" 
   last_name "Brookins" 
   escaped_email "a\\.m\\.brookins\\@example\\.com" 
   user_id "1000"

FT.SEARCH users-idx "@escaped_email:a\\.m\\.brookins\\@example\\.com"
```

### Spelling Error Correction

The **fuzzy** operator (`%`) enables fuzzy search for spelling errors, with the number of % signs determining the maximum Levenshtein distance.

```bash
FT.SEARCH books-idx "%adress%" HIGHLIGHT
```

Alternatively, `SPELLCHECK` provides suggestions for misspelled words. A common practice is to check if a query returns results, and if not, use `SPELLCHECK`. This feature supports languages like English, French, German, Italian, and Spanish. I will cover how to customize the spellcheck dictionary in a future post.

```bash
> FT.SPELLCHECK books-idx wizrds
1) 1) "TERM"
   2) "wizrds"
   3) 1) 1) "0.0014684287812041115"
         2) "wizards"
```
