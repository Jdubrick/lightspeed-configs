# Provider Configuration

Each inference has its own environment variables. You can include all of these in an env file and pass it to your container. Use [default-values.env](./env/default-values.env) as a template, and copy it to `values.env` for local edits.

> [!IMPORTANT]
> These are `.env` values, so avoid wrapping values in quotes unless required by the provider.
>
> `VLLM_API_KEY=token` (recommended)
>
> `VLLM_API_KEY="token"` (can cause parsing issues)

> [!NOTE]
> OpenAI, vLLM, and Vertex are always declared under `llama_stack.config.native_override.providers.inference` in [lightspeed-stack.yaml](../lightspeed-core-configs/lightspeed-stack.yaml). Enable a provider by setting `ENABLE_OPENAI=true`, `ENABLE_VLLM=true`, or `ENABLE_VERTEX_AI=true` in `env/values.env` (empty skips via OGX `${env.ENABLE_*:+id}`), plus that provider's API key/URL vars.
>
> For GitOps/production, [scripts/generate-gitops-manifests.sh](../scripts/generate-gitops-manifests.sh) adds production `allowed_models` on the native OpenAI and Vertex `config` blocks.
>
> Ollama is not a tracked provider — add it manually to `.local.yaml` under the same `native_override.providers.inference` list — see the Ollama section below.

## vLLM

Set `ENABLE_VLLM=true` plus `VLLM_API_KEY` and `VLLM_URL` on the Lightspeed Core container. The tracked native block is:

```yaml
- provider_id: ${env.ENABLE_VLLM:+vllm}
  provider_type: remote::vllm
  config:
    api_token: ${env.VLLM_API_KEY}
    base_url: ${env.VLLM_URL:=}
    max_tokens: ${env.VLLM_MAX_TOKENS:=4096}
    network:
      tls:
        verify: ${env.VLLM_TLS_VERIFY:=true}
```

## Ollama
> [!NOTE]
> Lightspeed Core does not implement the "official" Ollama provider via Llama stack (remote::ollama), instead we can access it via the vLLM provider.
>

To add the `ollama` inference provider, paste the following into `native_override.providers.inference` in `lightspeed-core-configs/lightspeed-stack.local.yaml` (Ollama is not a tracked provider — add it manually). High-level `inference.providers` cannot be used for this: `native_override` replaces the inference list wholesale.

```yaml
- provider_id: ollama
  provider_type: remote::vllm
  config:
    base_url: ${env.OLLAMA_URL:=http://localhost:11434/v1}
```

`OLLAMA_URL` guidance:

- If Lightspeed Core runs directly on your host, use `http://localhost:11434/v1`.
- If Lightspeed Core runs in a container, use `http://host.containers.internal:11434/v1`.
- On Linux, you may need to open firewall access to the Podman network or run with `--network host`.

## OpenAI

Set `ENABLE_OPENAI=true` and pass `OPENAI_API_KEY` to the Lightspeed Core container. The tracked native block is:

```yaml
- provider_id: ${env.ENABLE_OPENAI:+openai}
  provider_type: remote::openai
  config:
    api_key: ${env.OPENAI_API_KEY}
```

Get your API key from [platform.openai.com](https://platform.openai.com/settings/organization/api-keys).

## Vertex AI (Gemini)

Set `ENABLE_VERTEX_AI=true` plus `VERTEX_AI_PROJECT` (and usually `VERTEX_AI_LOCATION`). The tracked native block is:

```yaml
- provider_id: ${env.ENABLE_VERTEX_AI:+vertexai}
  provider_type: remote::vertexai
  config:
    project: ${env.VERTEX_AI_PROJECT:=}
    location: ${env.VERTEX_AI_LOCATION:=global}
```

Additionally, you need to ensure your Google Application Credentials are mounted to the Lightspeed Core container and the `GOOGLE_APPLICATION_CREDENTIALS` environment variable is the path to the mount location.

To set this up with the provided `compose/compose.yaml`, set `GOOGLE_APPLICATION_CREDENTIALS_HOST_PATH` to the path on your host machine of a GCP service account JSON key (or your `gcloud auth application-default login` credentials file). The compose file mounts that file into the container and points `GOOGLE_APPLICATION_CREDENTIALS` at the mounted path for you — do not set `GOOGLE_APPLICATION_CREDENTIALS` to a host path yourself, since that path won't exist inside the container.

```env
ENABLE_VERTEX_AI=true
VERTEX_AI_PROJECT=
VERTEX_AI_LOCATION=
GOOGLE_APPLICATION_CREDENTIALS_HOST_PATH=<path-on-your-host-to-a-gcp-service-account-json-key>
```

The service account (or `gcloud auth application-default login` credentials) needs the `Vertex AI User` role, and the Vertex AI API must be enabled on `VERTEX_AI_PROJECT`.

Provider details: [Llama Stack (OGX) Vertex AI docs](https://ogx-ai.github.io/docs/providers/inference/remote_vertexai).

For GitOps/production, [generate-gitops-manifests.sh](../scripts/generate-gitops-manifests.sh) adds `allowed_models` to this native `config` block. If the production shape changes, update the tracked block and/or `add_inference_allowed_models` in that script.

## Restricting Models (`allowed_models`)

Each of the providers above supports an `allowed_models` field to limit which models get registered with Llama Stack. This is most useful for `openai` and `vertexai`, since they auto-discover every model available to your account/project unless restricted.

To use it locally, add `allowed_models` under the provider's native `config` block in `lightspeed-core-configs/lightspeed-stack.local.yaml`. For GitOps/production, [generate-gitops-manifests.sh](../scripts/generate-gitops-manifests.sh) overlays production `allowed_models` automatically for `openai` and `vertexai`.

Open AI example:
```yaml
- provider_id: ${env.ENABLE_OPENAI:+openai}
  provider_type: remote::openai
  config:
    api_key: ${env.OPENAI_API_KEY}
    allowed_models:
      - gpt-4o
      - gpt-4o-mini
```

If `allowed_models` is omitted, all models the provider can see are registered.

## Full Example

The example below illustrates `native_override` inference with OpenAI and vLLM gated by `ENABLE_*`. Ollama is optional and shown here for illustration only.

```yaml
name: lightspeed-core-stack
service:
  host: ${env.SERVICE_HOST:=127.0.0.1}
  port: 8080
  auth_enabled: false
  workers: 1
  color_log: true
  access_log: true
llama_stack:
  use_as_library_client: true
  config:
    baseline: default
    native_override:
      providers:
        inference:
          - provider_id: sentence-transformers
            provider_type: inline::sentence-transformers
          - provider_id: ${env.ENABLE_OPENAI:+openai}
            provider_type: remote::openai
            config:
              api_key: ${env.OPENAI_API_KEY}
              allowed_models:
                - gpt-4o
                - gpt-4o-mini
          - provider_id: ${env.ENABLE_VLLM:+vllm}
            provider_type: remote::vllm
            config:
              api_token: ${env.VLLM_API_KEY}
              base_url: ${env.VLLM_URL:=}
              max_tokens: ${env.VLLM_MAX_TOKENS:=4096}
              network:
                tls:
                  verify: ${env.VLLM_TLS_VERIFY:=true}
          - provider_id: ollama
            provider_type: remote::vllm
            config:
              base_url: ${env.OLLAMA_URL:=http://localhost:11434/v1}
user_data_collection:
  feedback_enabled: true
  feedback_storage: '/tmp/data/feedback'
authentication:
  module: 'noop'
conversation_cache:
  type: 'sqlite'
  sqlite:
    db_path: '/tmp/cache.db'
customization:
  profile_path: '/app-root/rhdh-profile.py'
mcp_servers:
  - name: mcp-integration-tools
    provider_id: 'model-context-protocol'
    url: 'http://localhost:7007/api/mcp-actions/v1'
    authorization_headers:
      Authorization: 'client'
```
