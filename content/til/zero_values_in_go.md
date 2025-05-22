---
date: '2025-05-22T21:35:22+07:00'
draft: false
title: 'Zero Values in Go'
category: 'Golang'
---

Each type in Go has a zero value, which is the default value assigned to a variable of that type when it is declared but not explicity initialized.

```go
var boolean bool // false
var integer int // 0
var float float64 // 0.0
var complex complex128 // (0+0i)
var str string // ""
var array [5]int // [0 0 0 0 0]
var slice []int // nil
var mapVar map[string]int // nil
var channelVar chan int // nil
var pointer *int // nil
var functionVar func() // nil
var interfaceVar interface{} // nil
```
