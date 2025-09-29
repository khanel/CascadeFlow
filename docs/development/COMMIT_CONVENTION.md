# Git Commit Message Guide for Everyone

In an open-source project with contributors worldwide, good commit messages are like notes that explain your changes to others. They make the project easier to work on, track, and understand. This guide shows you how to write commit messages that are simple, clear, and helpful—whether you're a beginner or an expert.

### Why This Matters
- **Helps Teamwork**: Others can quickly see what you did and why.
- **Keeps History Clear**: Easy to find changes or fixes later.
- **Works with Tools**: Lets programs create changelogs automatically.

Let's dive into how to write commit messages step by step!

---

## The Basic Structure
Every commit message has up to three parts. Here's what it looks like:

```
<type>[optional scope]: <subject>

[optional body]

[optional footer]
```

### What Each Part Means
- **`type`**: What kind of change you made (e.g., adding a feature or fixing a bug).
- **`scope`** (optional): Which part of the project you changed (e.g., "login" or "docs").
- **`subject`**: A short line (under 50 characters) saying what you did.
- **`body`** (optional): More details if needed, like why you made the change.
- **`footer`** (optional): Extra notes, like if your change breaks something or links to an issue.

Don't worry—it's simpler than it sounds! Let's break it down with examples.

---

## Step 1: Pick a Type
The **type** tells everyone what your change does. Choose one from this list:

| Type       | Description                                      | When to Use It                          |
|------------|--------------------------------------------------|-----------------------------------------|
| `feat`     | Adds something new for users                   | Adding a button, page, or feature       |
| `fix`      | Fixes a problem or bug                        | Correcting an error                     |
| `docs`     | Changes to instructions or README             | Updating guides or notes                |
| `style`    | Changes how code looks (no behavior change)   | Fixing spaces or formatting             |
| `refactor` | Rewrites code without adding/fixing anything  | Making code cleaner or simpler          |
| `test`     | Adds or updates tests                         | Writing test cases                      |
| `chore`    | Small tasks or updates                        | Updating tools or settings              |
| `build`    | Changes to how the project builds             | Tweaking build scripts                  |
| `ci`       | Updates to automated workflows                | Changing GitHub Actions or CI setup     |
| `perf`     | Makes things faster                           | Speeding up code                        |
| `revert`   | Undoes a previous change                      | Canceling an earlier commit             |

**Example**: If you added a login button, use `feat`. If you fixed a typo in the README, use `docs`.

---

## Step 2: Add a Scope (Optional)
The **scope** says which part of the project you changed. It's optional but super helpful in big projects.

- **How to Use It**: Put it in parentheses after the type, like `feat(login)`.
- **Examples**:
  - `feat(login)`: A new login feature.
  - `fix(api)`: A fix in the API code.
  - `docs(readme)`: A change in the README file.

**Tip**: Keep it short—use a file name, module, or section of the project.

---

## Step 3: Write a Subject
The **subject** is a quick description of your change. It's the first line everyone sees.

### Rules
- Keep it short (under 50 characters).
- Use **command form** (like "add" or "fix," not "added" or "fixed").
- Make it clear what you did.

### Examples
- `feat: add reset password button`
- `fix: stop app crash on logout`
- `docs: explain how to install`

**Tip**: Think of it like finishing this sentence: "This commit will… [subject]."

---

## Step 4: Add a Body (Optional)
The **body** gives more details if the subject isn't enough. It's like a little story about your change.

### What to Include
- **What** you changed.
- **Why** you changed it (not how—let the code show that).
- Keep lines under 72 characters so they're easy to read.

### Example
```
feat: add user signup form

This adds a form where new users can sign up with their email and password.
It's needed because users couldn't register before.
```

**Tip**: Skip the body for simple changes, like fixing a typo.

---

## Step 5: Add a Footer (Optional)
The **footer** is for extra info, like:
- **Breaking Changes**: If your change stops old code from working.
- **Issue Links**: If your change fixes a bug report or task.

### How to Show Breaking Changes
- Add a `!` after the type/scope (e.g., `feat!:`).
- OR write `BREAKING CHANGE:` in the footer with details.

### Examples
- Breaking change:
  ```
  feat!: delete old search feature

  BREAKING CHANGE: The old search is gone. Use the new one instead.
  ```
- Issue link:
  ```
  fix: stop button from disappearing

  Fixes #789
  ```

**Tip**: Always warn about breaking changes so others know!

---

## Best Practices (Tips for Success)
Here's how to make your commit messages awesome:

1. **Keep Commits Small**: Change one thing per commit—it's easier to describe.

---

## TDD Commit Flow
When working through the red→green→refactor loop, split your work into three commits:

1. **Red** – add only the failing tests. Do not include production code changes yet.
1. **Green** – implement the minimal code needed to make the new tests pass.
1. **Refactor** – clean up the production code and tests without changing behaviour. In this phase, verify that you:
   - eliminate duplication and follow SOLID/DRY principles without altering behaviour
   - improve naming, structure, and readability for future contributors
   - optimise for performance or resource usage where the new code introduced overhead
   - ensure error handling, logging, and edge cases are consistent with project conventions
   - keep the public API stable and update docs/comments if signatures or responsibilities shift
   - rerun the full suite to confirm everything stays green after refactoring

Each commit should stay focused on its phase so the history shows the TDD progression clearly.

1. **Be Clear**: Avoid "Did stuff" or "Fixed it." Say what you did!
1. **Use Commands**: Write "add button," not "button added."
1. **Short Subjects**: Stick to 50 characters or less.
1. **Explain Why**: Tell us the reason for the change, not the coding steps.
1. **Link Issues**: Add "Closes #123" if it solves a task or bug.
1. **Wrap Lines**: Keep body/footer lines under 72 characters.

---

## Full Examples to Copy
Here are some commits you can use as templates:

### Adding a Feature
```
feat: add dark mode switch

Turns the app dark for better night viewing.
```

### Fixing a Bug
```
fix(login): stop crash on wrong password

The app crashed if the password was wrong. Now it shows an error instead.
```

### Updating Docs
```
docs(guide): add steps to run project

New users needed clearer setup instructions.
```

### Breaking Change
```
feat!: remove old menu system

BREAKING CHANGE: Old menu is gone. Use the new sidebar instead.
```

### Linking an Issue
```
feat: add user logout button

Lets users sign out safely.
Closes #456
```

---

## Writing Multi-Line Commit Messages in Terminal

When you're working in your terminal, you may want to write multi-line commit messages without opening an editor. Here are several ways to do it:

### Using `$'...'` Syntax in Zsh

In Zsh (and some other shells), you can use the `$'...'` syntax with `\n` for line breaks:

```
git commit -m $'feat: add user logout feature\n\nThis adds a logout button to the user menu.\nIt ensures sessions are closed securely.\n\nCloses #456'
```

This produces a properly formatted multi-line commit message:
```
feat: add user logout feature

This adds a logout button to the user menu.
It ensures sessions are closed securely.

Closes #456
```

### Other Ways to Create Multi-Line Messages

1. **Let Git open an editor** (simplest approach):
   ```
   git commit
   ```
   Git will open your configured editor where you can type a multi-line message.

1. **Using multiple `-m` flags**:
   ```
   git commit -m "feat: add user logout feature" -m "This adds a logout button to the user menu." -m "Closes #456"
   ```
   Each `-m` creates a new paragraph in your message.

**Tip**: The `$'...'` syntax is especially convenient for scripts or when you want to quickly create a properly formatted multi-line commit without opening an editor.

---

## Mistakes to Avoid
- **Vague Messages**: "Update" doesn't tell us anything—say what changed.
- **No Type**: Always start with `feat`, `fix`, etc.
- **Long Subjects**: Over 50 characters? Shorten it!
- **Too Much Detail**: Don't explain code lines—focus on why it matters.
- **Ignoring Breaks**: Tell us if your change breaks something!

---

## Tools to Make It Easier
- **Commitizen**: A tool that asks questions to build your message.
- **IDE Help**: VS Code and other editors have commit message plugins.
- **Git Hooks**: Set up rules to check your messages automatically.

---

## Extra Help
Want to learn more? Check these out:
- [Conventional Commits Website](https://www.conventionalcommits.org/en/v1.0.0/)
- [Git Commit Tips](https://cbea.ms/git-commit/)

---

## Quick Recap
- **Type**: Pick one (e.g., `feat`, `fix`).
- **Scope**: Add it if it helps (e.g., `(login)`).
- **Subject**: Short and clear (e.g., "add login page").
- **Body**: More info if needed.
- **Footer**: Breaking changes or issue links.

That's it! Follow this guide, and your commit messages will help everyone—newbies and pros alike. Thanks for making this project better with great commits!