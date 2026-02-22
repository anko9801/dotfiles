# Unix Philosophy

Part of [Cognitive Ergonomics](ergonomics.md#cognitive-ergonomics).

"Do One Thing and Do It Well" (DOTADIW)

## Core Principles

From Doug McIlroy (1978):
1. Make each program do one thing well
2. Write programs to work together
3. Write programs to handle text streams

## The Bloat Problem

Zawinski's Law: "Every program attempts to expand until it can read mail."

Unused features add cognitive load, more bugs, slower startup.

## Acceptable Consolidation

mise combines version management + env vars + task runner.
Justified because these concerns are tightly coupled in practice.
Single config file reduces context switching while each feature remains polished.

## References

- [Unix Philosophy - Wikipedia](https://en.wikipedia.org/wiki/Unix_philosophy)
- [The Art of Unix Programming](http://www.catb.org/~esr/writings/taoup/html/)
