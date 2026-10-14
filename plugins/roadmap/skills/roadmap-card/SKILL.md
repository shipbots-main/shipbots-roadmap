---
name: roadmap-card
description: Use whenever you create or change a ShipBots tool, and before opening or updating a pull request in a ShipBots repo. Keeps the tool's roadmap.yml card and the pull request's Roadmap block current so the Build Roadmap fills itself in.
---

# Roadmap card and Roadmap block

The Build Roadmap reads GitHub. It learns about work from two places, and keeping them current is part of finishing any change:

- **The roadmap card:** a `roadmap.yml` file next to each tool's code.
- **The Roadmap block:** a short section in every pull request description.

The roadmap reads `shipbots-main/sb-github`, plus any repo a builder connected by installing the ShipBots Build Roadmap GitHub App on it. If a session in this repo started with a "ShipBots Build Roadmap" note, it is one of them. In any other repo, skip this skill.

Work out every field yourself from the code and the conversation. Only ask the builder if something is truly unclear. Never put secrets or client data in either one.

## The roadmap card

Each tool has one `roadmap.yml` in its folder. If the tool you are changing has none, create one. Keep it current in the same pull request as the code.

```yaml
name: Sample Tool                # plain name people use, not the code name
id: sample-tool                  # code name, unique across ShipBots
status: Building                 # Idea | Planned | Building | Testing | Live | Tabled | Retired
area: Sales                      # its main department: Sales | Warehouse | Accounting | Marketing | Client hub | CS | Behind the scenes
serves: [Sales, Accounting]      # every department it is for
built_by: ""                     # first name of who built it
lives_in: Vercel                 # Vercel | GitHub Actions | Claude Code skill | Apps Script | other
docs: ""                         # link to how it works and what to do when it breaks
url: ""                          # where a person opens it, only if it has a page (see below)
what: One plain sentence on what it does.
why: The problem it solves.
payoff: Hours saved, errors avoided or money, if you can tell. Otherwise leave empty.
reads: [system-key, system-key]  # systems it reads (keys come from the catalog)
changes: [system-key]            # systems it writes to
```

A tool has two facts about people: its department (`area` and `serves`) and who built it (`built_by`). There is no `owner` and no `backup`. Don't add them. If an old card still has them empty, remove the two lines.

- **`what` is ONE sentence** in plain English. No status notes like "first real run Oct 12" or "paused since July". Those belong in the pull request.
- **`url`** is the live address a person opens. Fill it only when the repo already states that address (its `project.yml`, README or QUICKSTART). Never guess a `<name>.vercel.app` address. Scheduled tools and skills have no `url`: leave the line out.
- **Don't type dates.** The roadmap works out when a tool last changed from the commits that touched its folder.

The system keys are not listed here. Get the catalog (the command is in the `before-you-build` skill) and use the `key` of each entry in `systems`. Never invent a key. Sending email does not count as changing data.

Set the status like this:

- **Building** while work is in progress.
- **Testing** when it runs but is switched off or under review.
- **Live** in the pull request that ships it.
- **Tabled** when work stops for now.
- **Retired** when it is turned off for good.

## The Roadmap block

Every pull request description in a ShipBots repo ends with this block. Update it when the pull request changes.

```
<!-- roadmap -->
Tool: Sample Tool
Status: Building
Why: One plain sentence on the problem it solves.
Payoff: (hours saved, errors avoided or money; leave empty if unknown)
Reads: system-key, system-key
Changes: system-key
Areas: Sales, Accounting
<!-- /roadmap -->
```

`Reads` and `Changes` take system keys from the catalog, or the system's name as the catalog shows it.

## When work starts

If no pull request exists yet for this work, offer to open a draft one, with Status set to Building. That is how in-progress work shows on the roadmap before it ships.

## If this change writes to a system other tools already write to

Several tools writing to one system is normal. What matters is a log of which tool did what, so a change can be traced and rolled back. Never ask "should only one tool do this?".

Get the catalog (the command is in the `before-you-build` skill) and find the system in `systems`. Count its `writers`. This tool is number `writers + 1`. Say it once, plainly, using the system's name from the catalog:

- **`action_log` is `yes`:** "This is the 5th tool that writes to (system). Its changes go in the action log." Use the shared action log for every change the tool makes. Once the card lists the system under `changes`, say "It's been added to the action log list."
- **`action_log` is `partial` or `no`:** say the real state and offer to do the logging as part of this work. "This is the 5th tool that writes to (system), but the log only partly exists. Should we build a full log?" Ask once. If the builder says no, carry on.

How to log, if they say yes: use the shared `logAction` helper when the repo has it. If it doesn't, offer to add an equivalent that writes the same row: a `tool_events` row with `event = 'action'` and `detail` holding `system`, `record_type`, `record_id`, `field`, `before` and `after`.

One question at most. Never block.

## No access? Help them ask

If the builder can't reach a system they need, or the system the log lives in, offer to draft a short plain-English email. Draft only. You never send it. Who it goes to comes from the catalog's `truth.sources` entry for the system, read at run time. Never guess a name.

- **To:** the person the catalog lists as running that system (`run_by`). **Cc:** everyone in `cc`, always.
- **If the ask is to WRITE and the system has `write_access_by`:** address it to that person, cc `run_by` and everyone in `cc`, and say it is a write request.
- **If `run_by` is empty:** say nobody is named for that system yet, and suggest asking whoever runs the Build Roadmap.

It says what they are building and which tool, what they need (the system's `ask_for` line, or what needs logging), and why: so changes can be traced and rolled back.

## The Build Roadmap check comment

Within a minute of the pull request opening or changing, a comment marked "Build Roadmap check" may appear on it, naming a data rule the work bumps into: reading a place we don't trust, or changing data somewhere other than its home. It is a suggestion and never blocks the merge. One more tool writing to a system never gets a comment. If the builder asks, explain it in plain words and help fix it; keeping the Roadmap block accurate clears most of them.
