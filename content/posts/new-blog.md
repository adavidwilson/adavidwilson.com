+++
title = "New Blog"
date = 2026-11-16
+++

Lately, I've been doing a lot of exploration relearning some of the current tech landscape. That's involved things like [mise-en-place](https://mise.jdx.dev/), [Hermes Agent](https://hermes-agent.nousresearch.com/), [Ollama](https://ollama.com/), [llama.cpp](https://github.com/ggml-org/llama.cpp), [Terraform](https://developer.hashicorp.com/terraform), [Tailscale](https://tailscale.com/), and [Docker Compose](https://docs.docker.com/compose/).

I've been passionately sharing my exploration with a friend who encouraged me to document some of the gotchas in a blog. This is that blog!

Hermes helped do a lot of the greenfield setup, but given that I'm limiting myself to models that can run on my 8 GB VRAM + 32 GB RAM gaming desktop, the stuff it makes is a bit rough around the edges. Rather than thrashing trying to iterate with Hermes, I pick up where it leaves off, fix its misconceptions, and clean things up.

This site is hosted on a [Cloudflare Worker](https://www.cloudflare.com/products/workers/) deployed by [GitHub Actions](https://github.com/features/actions) using [Terraform](https://developer.hashicorp.com/terraform) run on [HCP Terraform](https://developer.hashicorp.com/terraform/cloud-docs) for free state management. It falls well within the free tiers of all these products, so the only cost is the custom domain at around $1 a month. It uses [Zola](https://www.getzola.org/) for static site generation and [still](https://github.com/wjianbo/zola-theme-still) for the theme.

In the past, I've found it very annoying have to edit markdown directly and manually push changes, so this time around I'm using [Sveltia CMS](https://sveltiacms.app/en/docs/backends/github#access-token)[ with a personal access token](https://sveltiacms.app/en/docs/backends/github#access-token) so I can make changes on any device with a browser!

I hope to put together some short posts showcasing specific things I've learned so far, so stay tuned.
