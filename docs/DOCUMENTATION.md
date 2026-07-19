# Documentation standard

How prose is written in this repository — doc comments, markdown docs, and
commit messages. The test for all three is the same: **documentation records
what the code cannot say.** Rationale, contracts, invariants, and trade-offs
belong in prose; anything a reader can recover from the code itself does not.

## Doc comments (`///`)

### When a doc comment is required

- **Type-level headers** on every Presenter, Store, engine simulator, engine
  action, protocol-witness struct, and persistence type. The header states the
  type's role and the reason behind any non-obvious design choice.
- **Members** only when the contract is not evident from the signature: units,
  side effects, failure modes, ordering requirements, isolation caveats, or a
  surprising interaction with another type.
- **Views, ViewModels, and small extensions** usually need none — their names
  and the layer rules in the README carry the meaning.

### Voice

Write complete sentences in the present tense. Lead with what the thing *is*
or *guarantees*, then why it is shaped that way. Name related types in
backticks so the connection is searchable.

```swift
// ✅ Explains the contract and the reason for the shape
/// Requests the next background wake-up, injected as a protocol witness so the
/// decision logic is testable even though the OS trigger is not.

// ❌ Restates the signature — delete on sight
/// Requests the next background wake-up.
/// - Parameter date: the date to request the wake-up for.
```

### Rules

- Never restate the signature. A comment that could be regenerated from the
  declaration is noise and must be deleted, not "improved".
- Prefer prose over `- Parameter:`/`- Returns:` bullet lists. Use the bullets
  only when several parameters carry non-obvious meaning individually.
- Wrap comment lines at roughly 80 columns, matching the existing files.
- Do not narrate implementation steps inside function bodies. An inline `//`
  comment is reserved for a constraint the code cannot express (a magic
  number's origin, a workaround's cause, an ordering that must not change).
- When behaviour mirrors or must stay in lockstep with another site, say so
  and name it — e.g. "matching the foreground contract in
  `PetPresenter.handleScenePhase`".

## Markdown docs

- **`README.md` is the map.** It owns the game-rules table, the architecture
  and layer rules, the folder map, and the build/test commands. Any commit
  that changes one of those updates the README *in the same commit* — a stale
  map is worse than no map.
- **`docs/` holds long-form documents**: this standard, and design docs for
  decisions whose trade-offs a future reader would otherwise re-litigate.
  A feature earns a design doc when the *why* is too large for a doc comment
  and too situational for the README — not merely because it was hard.
- File names are kebab-case (`sprite-pipeline.md`, `save-migration.md`).
- **`Tools/README.md` stays with `Tools/`** — docs for a self-contained
  directory live in that directory.
- Delete docs whose subject is gone. Git remembers; the working tree should
  only describe the present.

## Commit messages

```
<prefix>: short description
- Action `Filename.swift` what changed
```

- **Prefixes**: `feat` | `fix` | `refactor` | `chore` | `test` | `docs`
- **Actions**: `Create` | `Delete` | `Update`
- The subject line describes the outcome in the imperative; the bullets list
  one line per file (or tightly-related file group) naming the concrete
  change, as in the existing history.
- Prose-only changes use the `docs` prefix.
- A commit that changes behaviour *and* its documentation ships both under
  the behaviour's prefix — documentation follows its subject.
