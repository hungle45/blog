---
date: '2026-03-30T16:33:40+07:00'
draft: false
title: 'ASCII vs. UTF-8'
---

### The 7-Bit History of ASCII

In the 1960s, ASCII used only 7 bits ($2^7 = 128$ characters).
The final bit was reserved for a **Parity Bit** to check for hardware errors during transmission.
Because of this design, standard ASCII only covers the range `0x00` to `0x7F`.

In modern systems, parity bits are no longer used for character encoding, so the first bit of a standard ASCII character is always set to `0`.

### UTF-8 Memory Representation

UTF-8 is a variable-width encoding (1 to 4 bytes).
It is backwards compatible because it uses the **Most Significant Bit (MSB)** of every byte to tell the CPU how to read the data.

| Number of Bytes | Byte 1 (Leader) | Byte 2     | Byte 3     | Byte 4     | 
|-----------------|-----------------|------------|------------|------------|
| 1 Byte          | `0xxxxxxx`      |            |            |            |
| 2 Bytes         | `110xxxxx`      | `10xxxxxx` |            |            |
| 3 Bytes         | `1110xxxx`      | `10xxxxxx` | `10xxxxxx` |            |
| 4 Bytes         | `11110xxx`      | `10xxxxxx` | `10xxxxxx` | `10xxxxxx` |

- Single-Byte (ASCII): Starts with `0`.
  - Pattern: `0xxxxxxx`
  - Range: `U+0000` to `U+007F` (0-127).
  - Example: `A` is `01000001`.

- Multi-Byte (Non-ASCII): Starts with 1.
  - The first byte tells you the length (e.g., `110xxxxx` means 2 bytes total).
  - All following bytes (continuation bytes) start with `10`.
  - Example: My name `Hùng` takes 5 bytes in memory because `ù` requires a 2-byte sequence (`11000011 10111001`).
