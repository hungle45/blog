---
date: '2026-02-08T15:48:58+07:00'
draft: true
showToc: false
title: 'Leetcode 110: Balanced Binary Tree'
tags: ["leetcode", "binary-tree", "dfs"]
---

{{< leetcode url="https://leetcode.com/problems/balanced-binary-tree" id="110" title="Balanced Binary Tree" difficulty="Easy" >}}

### Approach: DFS

#### Intuition

The problem asks us to determine whether a binary tree is balanced. A binary tree is balanced if the height difference between the left and right subtrees of any node is at most 1.

We can use a depth-first search (DFS) approach to determine if a binary tree is balanced. The idea is to traverse the tree and check if the height difference between the left and right subtrees of each node is at most 1. If we find a node where the height difference is greater than 1, we return false. Otherwise, we return true.

The cost of traversing all nodes in the tree is $O(n)$ and the cost of calculating the height of each node is $O(n)$. Therefore, the total time complexity is $O(n^2)$. To optimize the time complexity, we can start from the leaf nodes and work our way up to the root. By doing this, we can avoid redundant height calculations by reusing the height value calculated from the children nodes.

#### Implementation

```python
class Solution:
    def isBalanced(self, root: Optional[TreeNode]) -> bool:

        def check_balance(node: Optional[TreeNode]) -> Tuple[bool, int]:
            if not node:
                return True, 0

            left_balanced, left_height = check_balance(node.left)
            right_balanced, right_height = check_balance(node.right)
            
            balanced = (left_balanced and right_balanced and 
                        abs(left_height - right_height) <= 1)
            current_height = max(left_height, right_height) + 1

            return balanced, current_height

        return check_balance(root)[0]
```

#### Complexity Analysis

- Time complexity: $O(n)$. We visit each node only once. Each visit takes constant time.

- Space complexity: $O(n)$. The space complexity is determined by the maximum depth of the call stack. In the worst case, the tree is skewed, and the call stack can have $O(n)$ nodes.
