# OpenCode Config

This directory is stowed to `~/.config/opencode/`.

Files:

- `opencode.json`: main OpenCode configuration for MCP and provider settings.

## Firecrawl MCP API Key (Optional)

If you use Firecrawl MCP, create the key file referenced by `opencode.json`:

```bash
mkdir -p ~/.config/opencode
printf '%s' 'fc-your-key-here' > ~/.config/opencode/firecrawl_api_key
chmod 600 ~/.config/opencode/firecrawl_api_key
```

The config reads this file via:

- `FIRECRAWL_API_KEY: {file:~/.config/opencode/firecrawl_api_key}`

## Vertex AI (Optional)

If you use the `google-vertex` provider, ensure your environment exports:

- `GOOGLE_CLOUD_PROJECT`
- `GOOGLE_APPLICATION_CREDENTIALS`
- `VERTEX_LOCATION`

In this repo, these are typically managed in shell config (for example
`fish/.config/fish/config.fish`).
