---
date: '2026-02-14T16:22:09+07:00'
draft: false
title: 'Leetcode 799: Champagne Tower'
showToc: false
tags: ['principle', 'dynamic-programming'] 
---

{{< leetcode url="https://leetcode.com/problems/champagne-tower/" id="799" title="Champagne Tower" difficulty="Medium" >}}

### Approach: Simulation

#### Intuition

In this problem, instead of simulating the final amount of champagne in each glass, we focus on the amount of champagne that flows through each glass.
Any amount exceeding one unit is considered excess and is split equally between the two glasses in the row below (bottom-left and bottom-right).
For example, if 10 units are poured into the top cup, 1 unit is retained and the remaining 9 units are distributed—4.5 units to each glass directly below.

#### Implementation

```python
class Solution:
    def champagneTower(self, poured: int, query_row: int, query_glass: int) -> float:
        memo = [0.0] * (query_row + 1)
        memo[0] = poured

        for i in range(1, query_row + 1):
            for j in range(i, -1, -1):
                overflow_left = max(0.0, memo[j - 1] - 1)
                overflow_right = max(0.0, memo[j] - 1)

                if j == 0:
                    memo[j] = overflow_right / 2.0
                elif j == i:
                    memo[j] = overflow_left / 2.0
                else:
                    memo[j] = (overflow_left + overflow_right) / 2.0

        return min(1.0, memo[query_glass])
```

#### Complexity Analysis

- Time complexity: $O(R^2)$ where $R$ is the `query_row`. We iterater through each glass in every row up to the target row.
- Space complexity: $O(R)$ for the `memo` array to store the current row's flow.
 