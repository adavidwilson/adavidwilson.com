+++
title = "Tailscale in Docker Compose"
date = 2026-11-16
+++

**TLDR:**

```yaml
service:
  tailscale:
    ...
  app:
    ...
    network_mode: service:tailscale
```

---

While developing my current local AI agent stack, I ran into an annoying oversight in the Tailscale docs.

The first thing you'll find if you do a web search for "Tailscale in Docker Compose" is a doc that leaves out that extremely important line in the compose file.[^tailscale-doc]

If you follow the doc without knowing better (like me!), you'll assume that you can access the `nginx` service from your tailnet. If you try, you'll be met with a refused connection and lines in your `tailscale` service log indicating nothing is being served on the port you tried to hit.

Even if both the `nginx` and `tailscale` services are in the same Docker network, Tailscale can't magically route traffic to a particular port on the other container. What the docs leave out is that the `nginx` service needs to use the service network mode.[^compose]

What the service network mode does is essentially treat both services as though they are on the same host: `localhost` on `tailscale` is `localhost` on `nginx`. That way, any ports served by your application services in the compose stack are immediately available to the `tailscale` service container as though they were being served by the same Docker image.

Eventually, I found the original example from 2024 detailing the solution, and finally got it to work\![^solution]

[^tailscale-doc]: [https://tailscale.com/docs/features/containers/docker/how-to/connect-docker-container](https://tailscale.com/docs/features/containers/docker/how-to/connect-docker-container)
[^solution]: [https://github.com/tailscale-dev/docker-guide-code-examples/blob/main/03-nginx-example/compose.yaml](https://github.com/tailscale-dev/docker-guide-code-examples/blob/main/03-nginx-example/compose.yaml)
[^compose]: [https://docs.docker.com/reference/compose-file/services/#network_mode](https://docs.docker.com/reference/compose-file/services/#network_mode)
