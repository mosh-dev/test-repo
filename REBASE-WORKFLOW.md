# Rebase workflow

Replacing "merge main into my feature branch" with rebase.

## The shape of it

**Rebase my branch onto main. Merge my branch into main.**

Two different places merges used to happen — only the first one changes:

| When | Before | Now |
|---|---|---|
| Catching up with main mid-work | `git merge main` | `git rebase main` |
| Landing finished work | merge / PR | merge / PR (unchanged) |

Because you rebased first, the final merge fast-forwards — so no merge commit appears there either.

### Direction matters

It is **"rebase my branch onto main"**, not "rebase main into my branch". Your commits get
lifted and replayed on top of main. **Main never moves.**

In WebStorm: on your feature branch, right-click `main` in the Branches popup →
**`Rebase feature/x onto main`**. Read it left to right — the first name is what moves, the
second is what it lands on. That is exactly `git rebase main`.

The neighbouring **Checkout and Rebase onto Current** does the opposite and moves `main`.
Avoid it.

## The one command that changes

**Before (merge-based):**

```powershell
git switch feature/x
git merge main
```

**After (rebase-based):**

```powershell
git switch main
git pull                        # get latest main

git switch feature/x
git rebase main                 # replay my commits on top of latest main
# conflicts? resolve -> git add <file> -> git rebase --continue

git push --force-with-lease     # only if the branch was already pushed
```

Run this as often as you used to run `git merge main`.

## Finishing up

Same as before — open a PR, or locally:

```powershell
git switch main
git merge --ff-only feature/x   # fast-forward, no merge commit
git push
```

`--ff-only` fails loudly if you forgot to rebase first. Useful guard.

## Optional config

```powershell
git config --global pull.rebase true
```

Makes `git pull` rebase instead of creating merge commits.

## Trade-offs

**Gain:** no `Merge branch 'main' into feature/x` noise; `main` stays linear, easy to read and bisect.

**Pay:** conflicts hit per-commit instead of once, and you must force-push.

Fine for solo branches. **If a teammate has pulled your branch, stick with merge** — don't rewrite history under them.

---

# Cheat sheet

## Before every rebase

```bash
git log --oneline main..HEAD    # what will be replayed
git branch backup               # cheap safety net
```

## The conflict loop

`git status` -> edit file -> `git add <file>` -> `git rebase --continue`

| Command | Meaning |
|---|---|
| `--continue` | resolved, carry on (never `git commit`) |
| `--abort` | undo the whole rebase, back to the start |
| `--skip` | **delete this commit** — rarely what you want |

## Interactive rebase

`git rebase -i main` — list is **oldest at top** (opposite of `git log`).

| Verb | Effect |
|---|---|
| `pick` | keep as-is |
| `reword` | keep changes, edit message |
| `squash` | fold into the commit **above**, combine messages |
| `fixup` | same, but discard this message |
| `drop` / delete the line | remove the commit |
| move a line | reorder |

## Push or pull?

```bash
git fetch
git status -sb
```

- `ahead N` only -> push
- `behind N` only -> pull
- `ahead N, behind M` -> diverged. If M is your own pre-rebase commits, **force-push**. Otherwise pull.

## Traps

- **Mid-rebase, `HEAD` is main, not you.** Accepting "HEAD's side" in a merge tool deletes your own commit — and git reports `Successfully rebased` anyway.
- A conflict means *write the line that should exist*, not *pick a side*. Self-check before `git add`: does the file still contain the change this commit was about?
- After rebasing a pushed branch: `git push --force-with-lease`. **Never `git pull`** — it resurrects the old history.
- Rewriting any commit rewrites every commit after it (new SHAs) — each commit records its parent.
- **Don't use Notepad as `core.editor`** — it writes a UTF-8 BOM that corrupts the rebase todo file. Use `code --wait` or `webstorm --wait`.

## Recovery

```bash
git reflog                       # everywhere HEAD has been
git reset --hard <sha>           # jump back to any of them
git reset --hard backup          # or use the backup branch
```

Nothing is lost for ~90 days, even after a bad rebase.

## Golden rule

Rebase freely on branches only you use. Don't rewrite history others have pulled.
