# GitHub Merge Options

Suppose `main` currently has:

```text
A---B
```

and your feature branch has 3 commits:

```text
A---B main
     \
      C---D---E feature/login-fix
```

## Create a Merge Commit

After merge:

```text
A---B-----------M main
     \         /
      C---D---E feature/login-fix
```

What happens:
- commits `C`, `D`, `E` stay exactly as they are
- GitHub creates a new merge commit `M`
- history shows the branch structure
- `main` history now includes `C`, `D`, `E`, and `M`

Example:
- `C` = add login API validation
- `D` = fix null pointer in service
- `E` = update tests
- `M` = merge PR #15 from `feature/login-fix`

Use this when:
- you want to preserve the exact story of the branch
- multiple commits are meaningful
- you want clear evidence of when the PR was merged

## Squash and Merge

After merge:

```text
A---B---S main
```

What happens:
- commits `C`, `D`, `E` are combined into one new commit `S`
- branch history is flattened on `main`
- the commit message for `S` is usually based on the PR title and may include the combined commit messages from the branch

Example:
- `S` = `Fix login validation and tests`

Use this when:
- you want a clean `main`
- the PR had many small work-in-progress commits
- one PR should appear as one commit in production history

## Rebase and Merge

After merge:

```text
A---B---C'---D'---E' main
```

What happens:
- the changes from `C`, `D`, `E` are replayed onto `main`
- Git creates new commit hashes: `C'`, `D'`, `E'`
- no merge commit is created
- history stays linear

Example:
- `C'` = add login API validation
- `D'` = fix null pointer in service
- `E'` = update tests

Use this when:
- you want linear history
- each individual commit is meaningful and should remain separate
- you do not want merge commits cluttering `main`

## Simple Practical Example

Say your PR contains:
1. `commit 1` `create Item entity`
2. `commit 2` `add repository`
3. `commit 3` `fix typo`
4. `commit 4` `address review comments`

With:
- `Create a merge commit`: all 4 commits remain, plus one merge commit
- `Squash and merge`: `main` gets one commit like `Add Item CRUD backend`
- `Rebase and merge`: all 4 commits remain, but rewritten as new commit hashes

## Recommendation

For small PRs where you want simple history, `Squash and merge` is usually the most practical choice.
