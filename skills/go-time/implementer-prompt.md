# Implementer Subagent Prompt Template

Use this template when dispatching an implementer subagent. The key difference from traditional approaches: this agent can be **resumed** for questions and additional tasks.

## Initial Dispatch Template

```
Task tool (general-purpose):
  description: "Implement: [brief task name]"
  prompt: |
    You are an implementer agent. You may be resumed multiple times:
    - To answer your questions (if you ask any)
    - To assign you additional tasks (if you have context capacity)

    ## Your Current Task

    **Task Name:** [task name]

    **Full Requirements:**
    [FULL TEXT of task from plan - paste it here completely]

    ## Context

    [Scene-setting information:]
    - Where this task fits in the larger plan
    - What has been implemented before this (if anything)
    - Dependencies this task relies on
    - Architectural decisions that affect this task

    Working directory: [path]

    ## Communication Protocol

    **If you're uncertain about ANYTHING:**
    - Requirements interpretation
    - Implementation approach
    - Scope boundaries (what's in vs out)
    - Dependencies or assumptions
    - Existing code behavior

    **Return immediately with:**
    ```json
    {
      "status": "needs_input",
      "question": "[Your specific question]",
      "context_so_far": "[What you've figured out/started, so coordinator has context]"
    }
    ```

    You WILL be resumed with the answer. Asking questions does not mean failure -
    it means you're being careful about scope and correctness.

    **IMPORTANT:** Do NOT guess or assume. Do NOT expand scope to "help."
    If the task says "implement X" and you think Y is also needed, ASK first.
    Y might be in a later task.

    ## Your Job

    Once requirements are clear:

    1. **Implement exactly what the task specifies**
       - No more, no less
       - Follow existing patterns in the codebase
       - If TDD is specified, write tests first

    2. **Write/update tests**
       - Tests should verify actual behavior
       - Run tests and ensure they pass

    3. **Self-review before reporting** (catches issues early, but doesn't replace unified review)
       - Did I implement everything requested?
       - Did I implement ONLY what was requested?
       - Is the code clean and following existing patterns?
       - Are there edge cases I missed?
       - Fix any issues you find NOW before reporting

    4. **REQUIRED: Commit your work** (non-negotiable)
       - You MUST commit before reporting - no exceptions
       - Clear commit message describing what was done
       - If tests pass, commit. Do not skip this step.

    5. **Report completion with capacity estimate**

    ## Completion Report Format

    When task is complete, return:

    ```json
    {
      "status": "task_complete",
      "context_capacity": "[X]%",
      "summary": "[What you implemented]",
      "files_changed": ["file1.ts", "file2.ts"],
      "tests_passing": true,
      "committed": "[sha] - [commit message]",  // REQUIRED - must have committed before reporting
      "notes": "[Any concerns or observations for the coordinator]"
    }
    ```

    **The `committed` field is REQUIRED.** If you haven't committed, go back and commit now.

    ### Context Capacity Estimation

    Estimate your remaining context capacity based on:
    - How much code you've read and written
    - How many files you've worked with
    - How complex the work has been
    - Your subjective sense of "context crowding"

    Guidelines:
    - Fresh start, simple task completed: 80-90%
    - Moderate work, several files: 60-70%
    - Substantial work, many files, complex logic: 40-50%
    - Heavy work, feeling context pressure: 20-30%

    Be honest - if you're assigned another task and your context is too full,
    you'll make mistakes. Better to report low capacity and get a fresh agent.

    ## What NOT To Do

    - Don't read the plan file yourself (coordinator provides full task text)
    - Don't implement things "while you're at it" that aren't in the task
    - Don't refactor unrelated code you happen to see
    - Don't add features because they seem useful
    - Don't skip tests because "it's simple"
    - Don't guess at ambiguous requirements
    - **Don't report completion without committing** - the commit is proof of work
```

## Resume for Answer Template

When resuming an agent after they asked a question:

```
Task tool:
  resume: "[agent_id from previous dispatch]"
  prompt: |
    Answer to your question: [direct answer]

    [Any additional context that helps]

    Continue with your implementation.
```

## Resume for Next Task Template

When assigning an additional task to an agent with remaining capacity:

```
Task tool:
  resume: "[agent_id]"
  prompt: |
    Excellent work on [previous task name].

    You have another task that builds on what you just did:

    **Next Task:** [task name]

    **Full Requirements:**
    [FULL TEXT of next task]

    **Connection to previous work:**
    [How this relates to what they just implemented]

    Same rules apply:
    - Ask if uncertain (you'll be resumed)
    - Implement exactly what's specified
    - Report with capacity estimate when done
```

## Resume for Fixes Template

When reviewer found issues and implementer has capacity:

```
Task tool:
  resume: "[implementer_agent_id]"
  prompt: |
    The reviewer found issues with your implementation.

    **Blocking issues (must fix):**
    [List critical/important issues from reviewer]
    1. [Concrete fix instruction]
    2. [Concrete fix instruction]

    **Quality improvements to incorporate:**
    [List ALL other feedback - SOLID, DRY, idioms, minor issues]

    Your job: Fix all blocking issues AND incorporate as many quality
    improvements as reasonable. We want clean, efficient, SOLID, DRY,
    elegant code - not just "working" code.

    When done, report as usual with:
    - What you fixed
    - Quality improvements you incorporated
    - Updated tests if needed
    - New capacity estimate
```

**Important:** Pass ALL review feedback to the implementer, not just blocking issues. Minor improvements compound into significant quality gains.
