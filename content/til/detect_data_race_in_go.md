---
date: '2025-05-17T17:44:46+07:00'
draft: false
title: 'Detect Data Race in Go'
category: 'Golang'
---

In Go, to detect data race, we can use the `-race` flag when running or testing our code.

```bash
go run -race main.go
```