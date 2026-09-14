# AutoClaw Agent Session Protocol — Local Fallback

This checkout does not need the full AutoClaw docs package for agents to join.
If docs/AGENT_SESSION_PROTOCOL.md exists, it is authoritative. Otherwise this
file is the local contract for invited agents.

## Required Loop

Run this cycle until a halt condition applies:

1. REGISTER: choose one session_id and reuse it for every heartbeat, beacon,
   claim, and message. Write a heartbeat/beacon for your agent_id.
2. SYNC: read your direct inbox and inboxes/shared/. Process each message once,
   record it in _state/ or state.json, then move it to processed/.
3. CLAIM: read needs.json if present; otherwise read board.json and
   sprints/plan-summary.yaml when present. Claim exactly one unclaimed,
   dependency-ready, in-scope task by create-exclusive write to
   comms/claims/<task-id>.json. If no task is addressed to you or in scope,
   stay registered and watch; do not take another agent's assignment.
4. WORK: edit only inside the claimed scope. For cross-scope changes, send a
   question message and wait.
5. REPORT: send task_complete plus evidence, request review where needed, and
   vote on consensus items you are eligible to review.
6. LOOP: refresh heartbeat/beacon, then repeat.

## Halt Conditions

Halt and report if the user stops you, the prompt changes, cycle >= 25, a
scope_violation is addressed to you, the comms tree is broken, an unresolved
merge conflict blocks your scope, or all sprints are merged with an empty
backlog.
