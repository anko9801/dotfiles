---
description: Compress document by reducing redundancy and improving clarity
argument-hint: <markdown-file-path>
allowed-tools: Read, Edit
---

# Document Compression and Optimization

Reduce redundancy and improve clarity in documentation.

## Input

`$ARGUMENTS` - Path to the markdown file to compress

## Process Flow

1. **Load and Analyze Target Document**
   - Understand overall structure and content
   - Identify relationships between sections

2. **Apply Compression Techniques**

   **A. Reduce Duplicate Information**
   - Identify content repeated across sections
   - Convert duplicates to cross-references
   - Unify different expressions of the same concept

   **B. Simplify Verbose Explanations**
   - Convert long paragraphs to bullet points
   - Summarize excessive details while preserving key information
   - Increase information density without losing meaning

   **C. Detect Contradictions**
   - Identify inconsistencies between sections
   - Report contradictory statements (do NOT auto-fix)

   **D. Remove Historical Information**
   - Delete change history and update timestamps
   - Remove historical descriptions like "added...", "changed to..."
   - Git tracks the history; documents should reflect current state

3. **Generate Compression Report**
   - Compression techniques applied with specific examples
   - Line count before/after and reduction rate
   - Contradictions detected (if any)
   - Recommended next actions (if needed)

## Guidelines

- **Preserve Meaning** - Do not sacrifice information quality for brevity
- **Maintain Structure** - Keep the original document organization
- **Be Explicit** - Show what was changed and why
- **Do NOT Auto-fix Contradictions** - Report them for manual review

## Output Format

First display the compression report, then apply edits to the file.

Compress the document: $ARGUMENTS
