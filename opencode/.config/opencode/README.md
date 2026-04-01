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

- `GOOGLE_CLOUD_PROJECT` (and optionally `GOOGLE_VERTEX_PROJECT`)
`GOOGLE_APPLICATION_CREDENTIALS`
- `GOOGLE_VERTEX_LOCATION` (and `VERTEX_LOCATION` for compatibility)

In this repo, keep these in a machine-local shell override (for example
`~/.config/fish/local.fish`) instead of committing them to dotfiles.

Example:

```fish
set -gx GOOGLE_VERTEX_PROJECT your-project-id
set -gx GOOGLE_VERTEX_LOCATION global
set -gx GOOGLE_APPLICATION_CREDENTIALS $HOME/.config/gcloud/application_default_credentials.json
```
