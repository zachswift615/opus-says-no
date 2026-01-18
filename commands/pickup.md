---
description: Pick up where the last session left off by loading the most recent handoff document
argument-hint: []
allowed-tools:
  - Read
  - Glob
  - Bash
---

<objective>
Find and load the most recent handoff document from `docs/handoffs/` to continue work from a previous session.
</objective>

<process>
1. **Find the latest handoff**: Use Glob to find `docs/handoffs/*-handoff.md` files
2. **Sort by filename**: Since files are dated (YYYY-MM-DD prefix), alphabetically last = most recent
3. **Read the handoff**: Load the full document
4. **Summarize and confirm**: Present a brief summary and ask what to work on first
</process>

<execution>
```bash
# Find handoff files sorted by name (most recent last due to date prefix)
ls -1 docs/handoffs/*-handoff.md 2>/dev/null | tail -1
```

If no handoff files found, inform the user there are no handoffs to pick up.

After reading the handoff document:

1. **Summarize the situation**:
   - Original goal and current status
   - Number of unresolved issues
   - The current hypothesis for the main blocker

2. **Ask what to prioritize**:
   - "Ready to continue. What would you like to tackle first?"
   - Or suggest starting with the top recommended next step from the handoff
</execution>

<success_criteria>
- Latest handoff document found and read
- User understands the session state in under 30 seconds
- Clear starting point for continued work
</success_criteria>
