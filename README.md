# ShipBots Build Roadmap plugin

GitHub is the database. The Build Roadmap page in the warehouse back end is a view of it. This plugin is the Claude Code side.

## How it works

1. **You start something new.** Claude reads the current rules and tools from GitHub: what already exists, where the data truth lives, who runs each system, and who else is building on the same data.
2. **Claude gives you context.** A few short lines. Read-only, a suggestion, never a blocker. Say "skip" and it skips.
3. **You build.** Claude keeps your tool's `roadmap.yml` card and the Roadmap block in your pull request current. That is the only thing it writes, and it lives in your own pull request.
4. **You open a pull request, then merge it.** Open pull request means in progress. Merged means shipped.
5. **The page shows it.** The roadmap is rebuilt from GitHub every 30 minutes and on every merge. If your pull request bumps into a data rule, one comment appears on it within a minute, saying which rule. It never blocks the merge.

## Before you start: two things

The plugin installs without them, but it stays silent until both are true. Each takes a minute.

1. **The GitHub command line tool (`gh`) is installed and signed in on your computer.** In a terminal:
   ```
   brew install gh
   gh auth login
   ```
   When it asks, choose **GitHub.com**, **HTTPS**, and **Yes** to "Authenticate Git with your GitHub credentials". Check it with `gh auth status`. The plugin uses this sign-in to prove you're on the team each time a session starts.
2. **Your GitHub username is saved on the Connect tab.** Open the warehouse back end, go to Team > Build Roadmap > Connect, and sign in with GitHub or type your username. Without it the plugin stays silent, because the roadmap doesn't know the username is yours.

## Setup, about 2 minutes

1. **Install the plugin.** Type these two lines in Claude Code:
   ```
   /plugin marketplace add shipbots-main/shipbots-roadmap
   /plugin install roadmap@shipbots
   ```
   Or the same thing from a terminal:
   ```
   claude plugin marketplace add shipbots-main/shipbots-roadmap
   claude plugin install roadmap@shipbots
   ```
2. **Turn on auto-update** so rule changes reach you: run `/plugin`, open Marketplaces, choose `shipbots`, then Enable auto-update.
3. **Start a new Claude Code session in a ShipBots repo.** You should see a short note that starts "ShipBots Build Roadmap for ...".

## If you see no note

Run this in a terminal from inside the repo, with your repo's `owner/name` at the end. It prints the note, or one line saying what's missing:

```
curl -s -H "Authorization: Bearer $(gh auth token)" "https://warehouse-portal-ship-bots.vercel.app/api/roadmap-context?repo=OWNER/REPO"
```

| It says | What to do |
|---|---|
| "GitHub user ... isn't on the ShipBots Build Roadmap yet" | Save your username on the Connect tab (step 2 above). |
| "GitHub didn't accept that sign-in" | Run `gh auth login` again. |
| Nothing at all | That repo isn't on the roadmap. Personal projects never get a note. |

## Building in your own GitHub account

The roadmap can also read a repo that lives in your own account, once you install the read-only **ShipBots Build Roadmap** GitHub App on it and pick that repo. Ask whoever runs the Build Roadmap whether it's switched on yet, and for the link. Your repo then shows on the page and gets a session note like any ShipBots repo. Choose "Only select repositories" when you install: every repo the app can see shows on the roadmap.

## What you get

| When | What happens |
|---|---|
| A session starts in a ShipBots repo | A short note: what's in this repo, where the data truth lives, data more than one tool changes, and who else is building on the same data. |
| You start something new | Claude offers a 5-line check, then offers to claim it by opening a draft pull request. |
| You change a tool | Claude keeps its `roadmap.yml` card and the pull request's Roadmap block current. You type nothing. |
| Your tool writes to a system other tools already write to | Claude says so plainly ("This is the 5th tool that writes to that system") and whether those changes are logged. If the log is missing or partial, it offers to build the logging into your work. It never asks you to stop. |
| You can't reach a system you need | Claude offers to draft a short email to the person the roadmap lists as running it, saying what you're building, what access you need and why. It only drafts. You send it. |
| Your pull request opens or changes | If it bumps into a data rule, one comment says which rule. A suggestion only. |
| Your pull request merges | The roadmap marks it shipped within minutes. |

## Privacy

- **Nothing is posted from your chats.** No code, secrets, client data or transcripts ever leave your computer through this plugin.
- At session start it sends only the repo's name and your GitHub sign-in, so the warehouse back end knows you're on the team.
- Repos that aren't in the ShipBots catalog get no note. Your personal projects stay private.
- This repo holds only the plugin. The roadmap itself (tools, rules, people) is served by the warehouse back end to signed-in team members and is not in this repo.

## Where things live

| Thing | Where |
|---|---|
| This plugin (two skills and a start-of-session hook) | `plugins/roadmap/` in this repo |
| The card format | `plugins/roadmap/skills/roadmap-card/SKILL.md` |
| The data rules, who runs each system, and the people list | The roadmap catalog, read at run time from the warehouse back end. They are files in `tools/build-roadmap/catalog/` in `shipbots-main/sb-github` (team only). Change them by pull request. |
| Which repos are on the roadmap | `shipbots-main/sb-github`, plus any repo a builder picked when installing the ShipBots Build Roadmap GitHub App |
| The job that builds the roadmap and checks pull requests | `tools/build-roadmap/` in `shipbots-main/sb-github` |
| The page | The Build Roadmap page in the warehouse back end |

To point the plugin somewhere else for testing, set `ROADMAP_URL` before starting Claude Code.
