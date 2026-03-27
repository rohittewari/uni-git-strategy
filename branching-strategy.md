# Branching Strategy for Single Repository

This document outlines the steps to set up branch protection rules for the `main` and `develop` branches in a single repository.

---

## **Steps to Set Up Classic Branch Protection Rules**

### **1. Go to Repository Settings:**
- Open your repository on GitHub.
- Click **Settings** in the top menu.

### **2. Navigate to Branch Protection Rules:**
- In the left sidebar, click **Branches**.
- Under **Branch protection rules**, click **Add classic branch protection rule**.

### **3. Set Up Rules for `main`:**
- In **Branch name pattern**, enter `main`.
- Enable the following:
  - **Require a pull request before merging**.
  - **Require status checks to pass before merging**.
    - Select at least one required status check (e.g., CI build, tests, or lint).
  - **Require branches to be up to date before merging**.
  - **Dismiss stale pull request approvals when new commits are pushed** (Recommended).
- Optionally enable:
  - **Require approvals**: Set to 1 or 2.
  - **Require conversation resolution before merging**.
  - **Restrict who can push to matching branches** (e.g., maintainers only).
  - **Do not allow force pushes**.
  - **Do not allow deletions**.
- Click **Create** or **Save changes**.

### **4. Repeat for `develop`:**
- Add another **classic branch protection rule**.
- In **Branch name pattern**, enter `develop`.
- Enable the same settings as for `main` (or adjust as needed).
- Click **Create** or **Save changes**.

---

## **Optional Recommended Settings**
While setting up the branch protection rules, consider enabling the following additional settings for better collaboration and security:

- **Dismiss stale pull request approvals when new commits are pushed** (Recommended).
- **Require approvals**: Set to 1 or 2.
- **Require conversation resolution before merging.**
- **Restrict who can push to matching branches** (e.g., maintainers only).
- **Do not allow force pushes on `main` and `develop` branches.**
- **Do not allow deletions on `main` and `develop` branches.**

---

## **@TODO: External CI/CD Service**
If you decide to use an external CI/CD service (e.g., CircleCI, Travis CI, or Jenkins) instead of GitHub Actions, you will need to:

1. Integrate the external CI/CD service with your GitHub repository.
2. Configure the external service to run checks on pull requests and pushes.
3. Ensure the external service reports status checks back to GitHub.
4. Once the external service is set up and running, the status checks will appear in the branch protection rule settings, where you can select them as required checks.

Let me know if you need guidance on setting up an external CI/CD service.

---

## **What Developers Will See**

When the PR branch is behind `main` or `develop`, GitHub will block the merge and show:
- **“This branch is out of date”**.
- The **Merge** button will be disabled.

### **How to Update the Branch**
Developers must update the branch by either:
- Clicking the **Update branch** button in the PR (if there are no conflicts).
- Or manually running the following commands:
  ```bash
  git fetch origin
  git merge origin/main  # Replace 'main' with 'develop' if updating against develop
  git push
  ```

After updating the branch:
- CI runs again.
- PR becomes mergeable.

---

## **Minimal GitHub Actions Workflow**
If you don’t have a CI check yet, here’s a simple workflow you can add:

1. Create a file `.github/workflows/basic-check.yml` in your repository.
2. Add the following content:
   ```yaml
   name: Basic Check

   on:
     push:
       branches:
         - main
     pull_request:

   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - name: Check out code
           uses: actions/checkout@v3
         - name: Run a simple test
           run: echo "Test passed!"
   ```

This will create a basic status check that you can require in the branch protection rule.

---

## **Summary**
To enforce the “out-of-date → block merge” rule for `main` and `develop`:

1. Protect both `main` and `develop` branches.
2. Require PRs for merging.
3. Require status checks to pass before merging.
4. Enable **Require branches to be up to date before merging**.
5. Optionally enable additional settings for approvals, conversation resolution, and push restrictions.

This setup ensures a robust and collaborative workflow for your repository.