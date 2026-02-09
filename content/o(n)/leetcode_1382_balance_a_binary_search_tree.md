---
date: '2026-02-09T11:24:53+07:00'
draft: false
title: 'Leetcode 1382: Balance a Binary Search Tree'
showToc: false
tags: []
---

{{< leetcode url="https://leetcode.com/problems/balance-a-binary-search-tree/" id="1382" title="Balance a Binary Search Tree" difficulty="Medium" >}}

### Overview

The problem asks us to balance a binary search tree (BST) such that the height of the tree is minimized. This means that for every node in the tree, the height of its left subtree and the height of its right subtree should differ by at most 1.

---

### Approach 1: DFS + Build Balanced BST

#### Intuition

Since the problem only requires to return a balanced BST with *the same node values*, we can simply extract all node values in sorted order from given BST by using inorder traversal.Having all extracted vaules, we can then construct a completely new Balance BST.

To build a Balance BST from a sorted array, we choose the middle item of the array as root node. This maintains the property that the difference in number of nodes in left subtree and right subtree is at most 1. Then, we apply this process recursively on the left and right subarrays to build subtrees. By doing so, we can build a balanced BST with the same node values as the original BST.

#### Implementation

```python
class Solution:
    def balanceBST(self, root: Optional[TreeNode]) -> Optional[TreeNode]:

        def get_sorted_list(root: Optional[TreeNode]) -> List[int]:
            if not root:
                return []
            return get_sorted_list(root.left) + [root.val] + get_sorted_list(root.right)

        sorted_list = get_sorted_list(root)

        def build_balanced_bst(sorted_list: List[int]) -> Optional[TreeNode]:
            if not sorted_list:
                return None
            mid = len(sorted_list) // 2
            return TreeNode(
                sorted_list[mid],
                build_balanced_bst(sorted_list[:mid]),
                build_balanced_bst(sorted_list[mid + 1 :]),
            )

        return build_balanced_bst(sorted_list)
```

#### Complexity Analysis

- Time complexity: $O(n)$. The cost of dfs is $O(n)$ and the cost of building new balanced tree is $O(n)$.
- Space complexity: $O(n)$. We need $O(n)$ space to store the sorted list and $O(logn)$ space for the recursion stack.

---

### Approach 2: Inplace balancing

I am aware that algorithms exist for in-place BST balancing by rotating nodes, like [Day-Stout-Warren (DSW)](https://en.wikipedia.org/wiki/Day%E2%80%93Stout%E2%80%93Warren_algorithm). However, I don't want to dive into that rabbit hole because it is rarely required in interviews, as the focus is typically on demonstrating a clear understanding of **tree traversals** and **recursive construction**. Therefore, I have opted to prioritize more practical approaches.
