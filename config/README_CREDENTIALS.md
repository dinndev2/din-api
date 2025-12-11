# Rails Credentials Setup

## Issue
Rails credentials may not read the master key from `config/master.key` file correctly in some cases.

## Solution: Use RAILS_MASTER_KEY Environment Variable

Instead of relying on the file, use the environment variable:

```bash
# Edit credentials
EDITOR="code --wait" RAILS_MASTER_KEY=$(cat config/master.key) bin/rails credentials:edit

# View credentials  
RAILS_MASTER_KEY=$(cat config/master.key) bin/rails credentials:show
```

## For Production

Set the `RAILS_MASTER_KEY` environment variable in your production environment:

```bash
# Get your master key
cat config/master.key

# Set it in production (example for Vercel/Railway/etc)
# In your hosting platform's environment variables:
RAILS_MASTER_KEY=your_master_key_here
```

## Current Master Key

Your master key is stored in `config/master.key`. **Never commit this file to git** (it's already in `.gitignore`).
