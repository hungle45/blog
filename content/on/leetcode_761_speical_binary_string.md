---
date: '2026-02-20T11:10:06+07:00'
draft: false
title: 'Leetcode 761: Speical Binary String'
showToc: false
tags: ['hard', 'string', 'divide-and-conquer', 'sorting', 'recursion']
---

{{< leetcode url="https://leetcode.com/problems/special-binary-string" id="761" title="Special Binary String" difficulty="Hard" >}}

### Approach:

#### Intuition

A special binary string is a binary string that has equal `1`s and `0`s with the property that every prefix has more or equal `1`s than `0`s.
The goal of this problem is to find the lexicographically largest special binary string given a special binary string by swapping two consecutive substrings any number of times.

To solve this problem, the key insight is to stop seeing the string as binary string and start seeing it as nested parentheses (I didn't figure it out on my own...).
For example, `101101001100` can be `()(()())(())`.
The reason for this is that a special binary string is exactly a valid parentheses string:

- `1` is an opening bracket `(` and `0` is an closing bracket `)`.
- The number of opening brackets equals the number of closing brackets.
- The brackets never close before they open.

A valid parentheses string can be divided into several valid parentheses substrings, and each substring has its own valid sub-substrings after removing the outermost parentheses.
For instance, `()(()())(())` can be divided into `()|(()())|(())` and `(()())` can be divided into two `()`.

So now, the swapping operation means swapping valid parentheses at the same level.
In the previous example, `()` [at index 0] and `(()())` [at index 2] have the same level while `()` [at index 0] and `()` [at index 3] have different level.
And because we can do swapping as many times as we want, we can reorder the valid parentheses at the same level.

To solve the problem, we just need to turn each individual block into its largest possible version by sorting their sub-blocks, like `(()(()))` is turned into `((())())`.
And then, we sort all processed blocks to get the largest lexicagraphical string.

#### Example workthrough: `1011011000`

```bash
Level 1: Initial call with s = "1011011000"
Found Block A: "10"
    Level 2: Recursion on inner ""
    Returns ""
Block A Result: "10"

Found Block B: "11011000"
    Level 2: Recursion on inner "101100"
    Found Sub-block B1: "10"
        Level 3: Recursion on inner "" -> Returns ""
    Sub-block B1 Result: "10"
    
    Found Sub-block B2: "1100"
        Level 3: Recursion on inner "10"
            Level 4: Recursion on inner "" -> Returns ""
        Level 3 returns: "10"
    Sub-block B2 Result: "1100"
    
    Level 2 Sorting: ["1100", "10"]
    Level 2 returns: "110010"
Block B Result: "1" + "110010" + "0" = "11100100"

Level 1 Final Sorting: ["11100100", "10"]
FINAL OUTPUT: "1110010010"
```

#### Implementation

```python
class Solution:
    def makeLargestSpecial(self, s: str) -> str:
        count = 0
        i = 0
        res = []
        
        for j in range(len(s)):
            count += 1 if s[j] == '1' else -1
            
            if count == 0:
                res.append('1' + self.makeLargestSpecial(s[i + 1:j]) + '0')
                i = j + 1 
                
        res.sort(reverse=True)
        return ''.join(res)
```

#### Complexity Analysis

- Time complexity: $O(n^2logn)$.
  - We have $O(n)$ recursive calls and in each call we do $O(n)$ work for string traversing and reconstructing the result.
  - The cost of sorting is $O(k \log k)$ where $k$ is the number of special substrings. In the worst case, $k$ can be $O(n)$.
- Space complexity: $O(n^2)$. The recursion depth is $O(n)$ and the space complexity for each call is $O(n)$ due to slicing and storing the results.
