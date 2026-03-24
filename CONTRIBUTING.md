# Contributing to This Repository

This guide is for Salesforce admins who are new to Git. It covers everything you need to work with this repo on a day-to-day basis.

---

## First-Time Setup

### 1. Install Git
Download and install Git from [https://git-scm.com/downloads](https://git-scm.com/downloads). Accept all defaults during installation.

### 2. Configure Git with your name and email
Open a terminal (Mac: Terminal app, Windows: Git Bash) and run:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@company.com"
```

### 3. Get access to the GitHub repository
Ask your team lead for access to the GitHub repository. You'll need a free GitHub account at [github.com](https://github.com).

### 4. Clone the repository to your computer
This creates a local copy of the repo on your machine:

```bash
git clone https://github.com/YOUR-ORG/YOUR-REPO-NAME.git
cd YOUR-REPO-NAME
```

---

## Day-to-Day Workflow

### Starting a new project

1. Make sure you have the latest version of `main`:
   ```bash
   git checkout main
   git pull
   ```

2. Create a new branch for your project:
   ```bash
   git checkout -b feature/your-project-name
   ```
   Use a short, descriptive name with dashes (e.g., `feature/opportunity-stage-update`).

3. Copy the project template:
   - Duplicate the `projects/_template/` folder
   - Rename it to your project name (e.g., `projects/opportunity-stage-update/`)
   - Fill in the `project-brief.md`

### Saving your work (committing)

After making changes to files, save them to the repo:

```bash
git add .
git commit -m "Brief description of what you changed"
```

Examples of good commit messages:
- `"Add deployment log for opportunity stage project"`
- `"Update rollback plan for Q2 release"`
- `"Add SOQL query for active accounts"`

### Sharing your work (pushing)

Push your branch to GitHub so others can see it:

```bash
git push origin feature/your-project-name
```

### Opening a Pull Request (PR)

When your project is ready to deploy to production:

1. Go to the repository on GitHub.
2. Click **"Compare & pull request"** next to your branch.
3. Fill out the PR template (the checklist will appear automatically).
4. Request a review from a teammate.
5. Once approved, the branch can be merged to `main`.

---

## Common Git Commands Reference

| Command | What it does |
|---|---|
| `git status` | Shows what files have changed |
| `git pull` | Gets the latest changes from GitHub |
| `git checkout main` | Switches to the main branch |
| `git checkout -b feature/name` | Creates and switches to a new branch |
| `git add .` | Stages all changed files for a commit |
| `git commit -m "message"` | Saves staged changes with a message |
| `git push origin branch-name` | Pushes your branch to GitHub |
| `git log --oneline` | Shows recent commit history |

---

## Rules

- **Never push directly to `main`.** Always use a branch and open a PR.
- **One branch per project.** Don't mix multiple projects on the same branch.
- **Fill out the PR template** before requesting a review.
- **Update your project folder** (`projects/<name>/deployment-log.md`) after each deployment.

---

## Getting Help

If you're stuck with Git, ask your team lead or check the [official Git guide](https://git-scm.com/book/en/v2/Getting-Started-What-is-Git%3F).
