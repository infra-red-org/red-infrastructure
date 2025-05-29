# Updating Git Remote URLs

## Overview

When a repository is moved to a new organization or user account on GitHub (or any Git hosting service), you don't need to delete your local copy and clone it again. Instead, you can simply update the remote URL to point to the new location.

This is especially important when you have uncommitted local changes that would be lost if you deleted the repository and cloned it again.

## Why This Matters

- **Preserves uncommitted changes**: Keeps all your local work that hasn't been pushed yet
- **Saves time**: No need to download the entire repository again
- **Maintains local configuration**: Preserves your local Git hooks, configs, and other customizations
- **Prevents data loss**: Eliminates the risk of accidentally deleting important work

## Step-by-Step Process

### 1. Check your current remote URL

```bash
cd /path/to/your/repository
git remote -v
```

This will display something like:
```
origin  git@github.com:old-owner/repository-name.git (fetch)
origin  git@github.com:old-owner/repository-name.git (push)
```

### 2. Update the remote URL

```bash
git remote set-url origin https://github.com/new-organization/repository-name.git
```

Or if you're using SSH:

```bash
git remote set-url origin git@github.com:new-organization/repository-name.git
```

### 3. Verify the change

```bash
git remote -v
```

This should now show the new URL:
```
origin  git@github.com:new-organization/repository-name.git (fetch)
origin  git@github.com:new-organization/repository-name.git (push)
```

### 4. Sync with the new remote

```bash
git pull
```

## Real-World Example

In our case, we updated from:
```
origin  git@github.com:seandavi/red-infrastructure.git (fetch)
origin  git@github.com:seandavi/red-infrastructure.git (push)
```

To:
```
origin  ssh://git@github.com/infra-red-org/red-infrastructure.git (fetch)
origin  ssh://git@github.com/infra-red-org/red-infrastructure.git (push)
```

This allowed us to keep working with our local repository without losing any uncommitted changes, while connecting to the repository in its new organization.

## Additional Tips

- If you're working with multiple remotes, you can update each one individually by specifying the remote name
- You can also use this technique to switch between HTTPS and SSH URLs
- This process works for any Git hosting service, not just GitHub