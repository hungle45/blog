---
date: '2026-02-15T16:40:02+07:00'
draft: false
title: 'Leetcode 67: Add Binary'
showToc: false
tags: ['string', 'bit-manipulation']
---

{{< leetcode url="https://leetcode.com/problems/add-binary/" id="67" title="Add Binary" difficulty="Easy" >}}

### Approach:

#### Intuition

The goal is to add two given string `a` and `b`, which represent the numbers in binary. We can think of it as two row of digits, add each column from the right to left, keep track the carry bit (like 1 + 1 results in 0 and carry 1 to the next row) and build the result string step by step.

#### Implementation

```python
class Solution:
    def addBinary(self, a: str, b: str) -> str:
        i, j = len(a) - 1, len(b) - 1
        carry = 0
        result = []

        while i >= 0 or j >= 0 or carry:
            sum = carry
            if i >= 0:
                sum += int(a[i])
                i -= 1
            if j >= 0:
                sum += int(b[j])
                j -= 1
            carry = sum // 2
            result.append(str(sum % 2))

        return "".join(result[::-1])
```

#### Complexity Analysis

- Time complexity: $O(\max(n, m))$ where $n$ and $m$ are the lengths of `a` and `b` respectively. We traverse each string at most once.
- Space complexity: $O(\max(n, m))$ for storing the result.
