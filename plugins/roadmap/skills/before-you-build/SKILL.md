---
name: before-you-build
description: Use at the start of any new ShipBots tool, page, automation, integration or big change, before writing code. Checks the team Build Roadmap for what already exists, where the data truth lives, who runs each system, whether changes to it are logged, and who else is building on the same data. A suggestion, never a blocker.
---

# Before you build

A quick check so nobody builds the same thing twice, reads data from a place we don't trust, or changes a system with no record of what changed. It should take under a minute. If the builder says "skip", skip it and carry on.

## 1. Get the catalog

Run:

```
curl -fsS -H "Authorization: Bearer $(gh auth token)" "${ROADMAP_URL:-https://warehouse-portal-ship-bots.vercel.app}/api/roadmap-catalog"
```

Your GitHub sign-in is how the warehouse back end knows you're on the ShipBots team. Nothing else is sent.

If it fails, or `gh` is not signed in, say "Couldn't reach the Build Roadmap, carrying on" in one line and continue with the work.

The catalog is built from GitHub every 30 minutes and on every merge. Everything about people and systems comes from it at run time. Nothing in this skill names a person or says who runs what. The catalog has these parts:

- `tools`: every roadmap card. Each has name, status, `area` and `serves` (its departments), `department_people` (who those departments are), `built_by`, what, why, reads, changes, `url` when it has a page, and `last_change`.
- `in_progress`: open pull requests, each with its Roadmap block.
- `shipped_14d`: pull requests merged in the last 14 days.
- `systems`: one per system (a CRM, a warehouse system, an accounting system and so on). `writers` is the list of tools that change it, oldest first. `action_log` is `yes`, `partial` or `no`: whether changes to it are logged (who changed what) so they can be rolled back. `action_log_note` says what is and isn't logged today.
- `truth.sources`: the same systems with who is around them. `run_by` (who runs it or gives access), `cc` (always copied on an access ask), `write_access_by` (who to ask for write access, when that is someone else), `main_users`, `automations_by`, `note`, and `ask_for` (what access to ask for).
- `truth.data`: where each kind of data lives and its rule. `rule_agreed: true` means the rule has been agreed, not just proposed. `decision` is a recorded decision and `decided_by` is who made it. `views` are places the truth is simply shown; they are fine. `do_not_trust` are the few places that give wrong answers.
- `new_writers`: open pull requests that add a tool to a system's writers.
- `overlaps`: systems that two or more people are building on right now.
- `people`: the team and their GitHub usernames.

## 2. Compare the idea to the catalog

Match on what it does, the data it would read and change, and the department it serves. Then tell the builder, in 5 short lines or fewer:

1. **Already exists:** the closest tools by plain name, and whether they already do most of this.
2. **Truth lives in:** the source of truth for the data this touches, and its rule. Mention a place only if it is in `do_not_trust`. Never warn about a view.
3. **Who to ask:** the person the catalog lists as running each system it needs (`run_by`), and what access to ask for (`ask_for`).
4. **Writes to:** see the next section. Leave this line out if the work changes nothing.
5. **Also building on it now:** people with open work on the same data. Leave this line out if there are none.

## 3. When the work writes to a system other tools already write to

Several tools writing to one system is normal. Those tools were built to do that. What matters is a log of which tool did what, so a change can be traced and rolled back. Never ask "should only one tool do this?".

Count the system's `writers` and say it plainly, using the system's name from the catalog. This tool is number `writers + 1`.

- **`action_log` is `yes`:** "This is the 5th tool that writes to (system). Its changes go in the action log." Use the shared action log for every change the tool makes. Once the tool's card lists the system under `changes`, say "It's been added to the action log list."
- **`action_log` is `partial` or `no`:** say the real state and offer to do the logging as part of this work. "This is the 5th tool that writes to (system), but the log only partly exists. Should we build a full log?" Use `action_log_note` for what is and isn't logged. Ask once. If the builder says no, carry on.

How to log, if they say yes:

- If the repo has the shared `logAction` helper, use it for every change the tool makes.
- If it doesn't, offer to add an equivalent that writes the same row: a `tool_events` row with `event = 'action'` and `detail` holding `system`, `record_type`, `record_id`, `field`, `before` and `after`.

One question at most. Never block.

## 4. No access? Help them ask

If the builder says they can't reach a system they need, or the system the log lives in, offer to draft a short plain-English email. Draft only. You never send it.

Who it goes to comes from the catalog's `truth.sources` entry for that system, read at run time. Never guess a name.

- **To:** the person the catalog lists as running that system (`run_by`).
- **Cc:** everyone in `cc`, always.
- **If the ask is to WRITE and the system has `write_access_by`:** address it to that person instead, cc `run_by` and everyone in `cc`, and say in the first line that it is a write request.
- **If `run_by` is empty:** say nobody is named for that system yet, and suggest asking whoever runs the Build Roadmap.

What it says, in a few short lines:

1. What they are building and which tool.
2. What they need: the access (use the system's `ask_for` line), or what needs logging.
3. Why: so changes can be traced and rolled back.

## 5. If someone else is building on the same data

Offer to draft one email to everyone involved, so replies stay in one thread. It names what each person is building and where the truth lives. Draft only.

If the builder and the person who runs a system settle a data rule, offer to record it: add `decision` and `decided_by` to that entry in `tools/build-roadmap/catalog/truth.yml`, in a pull request to `shipbots-main/sb-github`. A suggestion only.

## 6. Offer to claim it

Ask: "Want me to claim this on the roadmap?" If yes:

1. Create a branch.
2. Add or update the roadmap card for this tool, using the `roadmap-card` skill.
3. Open a draft pull request with `gh pr create --draft`. The description holds the Roadmap block from the `roadmap-card` skill, with Status set to Building.

The draft pull request is the claim. It shows the work as in progress on the roadmap right away.

## Never

- Never send code, secrets, client data or transcripts anywhere.
- Never send an email. You only draft.
- Never ask whether only one tool should change a system.
- Never stop the builder from building.
