+++
title = "Dotfile Management with mise-en-place"
date = 2026-11-18
+++

**TLDR:**

```bash
# Configure the watcher
cat <<‘EOF’ > "~/.config/mise/config.toml"
[bootstrap.services.mise-history]
builtin = "history-watch"
EOF

# Track at least mise's own config to github
mise dot track ~/.config/mise
mise bootstrap services apply
mise dot origin set https://github.com/you/dotfiles.git --sync sync

# Check status
mise dot status

# Check files
mise dot paths

# On another machine
mise bootstrap --adopt you/dotfiles
```

***

Sometime last week when this tech urge came upon me, I decided to try managing [my dotfiles](https://github.com/adavidwilson/dotfiles) again.

In the past, I’ve used [bare repos](https://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server.html) and \[`chezmoi`\](https://www.chezmoi.io/), but much like my previous blogs, I found myself abandoning and eventually deleting my configurations.

I think the biggest reason was wanting to iterate fast without using bespoke commands to edit my config files, add the changes to the repo, or push them to the remote.

[`mise`](https://mise.jdx.dev/) solves that problem with a filesystem watcher that also periodically fetches and pushes changes.

I have yet to explore all of the features `mise` has to offer, but I’m comfortable with the dotfile and package bootstrapping. It solves my problem keeping my laptop and desktop in sync.

See the [Arch Wiki](https://wiki.archlinux.org/title/Dotfiles) for more info.
