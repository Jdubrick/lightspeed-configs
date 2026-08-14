# Provider Configuration

Each inference has its own environment variables. You can include all of these in an env file and pass it to your container. Use [default-values.env](./env/default-values.env) as a template, and copy it to `values.env` for local edits.

> [!IMPORTANT]
> These are `.env` values, so avoid wrapping values in quotes unless required by the provider.
>
> `VLLM_API_KEY=token` (recommended)
>
> `VLLM_API_KEY="token"` (can cause parsing issues)
> 
> You will notice the `api_key_env` field is not wrapped in curly-braces `{}`. This is due to Lightspeed Core wrapping them internally to curate a proper `{env.xyz}` to pass through to Llama Stack so the keys are not exposed internally.

> [!NOTE]
> Commented provider stubs for `vllm`, `openai`, and `vertexai` live in [lightspeed-stack.yaml](../lightspeed-core-configs/lightspeed-stack.yaml). For local development, copy that file to `lightspeed-core-configs/lightspeed-stack.local.yaml` (gitignored, auto-mounted by `make local-up` when present — see [CONTRIBUTING.md](./CONTRIBUTING.md)), uncomment the block(s) you need, and set the required env vars.
>
> For GitOps/production, [scripts/generate-gitops-manifests.sh](../scripts/generate-gitops-manifests.sh) uncomments those three providers, then adds production `allowed_models` for `openai` and `vertexai`.
>
> Ollama is not a tracked stub — add it manually to `.local.yaml` using the Ollama section below.

## vLLM

To add the `vLLM` inference provider, uncomment the corresponding block in [lightspeed-stack.yaml](../lightspeed-core-configs/lightspeed-stack.yaml) (via `lightspeed-core-configs/lightspeed-stack.local.yaml` for local development). The stub looks like:

```yaml
inference:
  providers:
    - type: vllm
      id: <your-unique-id>
      api_key_env: VLLM_API_KEY
      extra:
        base_url: ${env.VLLM_URL:=}
        max_tokens: ${env.VLLM_MAX_TOKENS:=4096}
        network:
          tls:
            verify: ${env.VLLM_TLS_VERIFY:=true}
```

In order for `vLLM` to configure properly, you must include environment variables named `VLLM_API_KEY` and `VLLM_URL` to the Lightspeed Core container.

## Ollama
> [!NOTE]
> Lightspeed Core does not implement the "official" Ollama provider via Llama stack (remote::ollama), instead we can access it via the vLLM provider.
>

To add the `ollama` inference provider, paste the following into `lightspeed-core-configs/lightspeed-stack.local.yaml` (Ollama is not a tracked stub — add it manually):

```yaml
inference:
  providers:
    - type: vllm
      id: <your-unique-id>
      extra:
        base_url: ${env.OLLAMA_URL:=http://localhost:11434/v1}
```

`OLLAMA_URL` guidance:

- If Lightspeed Core runs directly on your host, use `http://localhost:11434/v1`.
- If Lightspeed Core runs in a container, use `http://host.containers.internal:11434/v1`.
- On Linux, you may need to open firewall access to the Podman network or run with `--network host`.

## OpenAI

To add the `openai` inference provider, uncomment the corresponding block in [lightspeed-stack.yaml](../lightspeed-core-configs/lightspeed-stack.yaml) (via `lightspeed-core-configs/lightspeed-stack.local.yaml` for local development). The stub looks like:

```yaml
inference:
  providers:
    - type: openai
      id: <your-unique-id>
      api_key_env: OPENAI_API_KEY
```

You must pass the environment variable `OPENAI_API_KEY` to the Lightspeed Core container.

Get your API key from [platform.openai.com](https://platform.openai.com/settings/organization/api-keys).

## Vertex AI (Gemini)

To add the `vertexai` inference provider, uncomment the corresponding block in [lightspeed-stack.yaml](../lightspeed-core-configs/lightspeed-stack.yaml) (via `lightspeed-core-configs/lightspeed-stack.local.yaml` for local development). The stub looks like:

```yaml
inference:
  providers:
    - type: vertexai
      id: <your-unique-id>
      extra:
        project: ${env.VERTEX_AI_PROJECT:=}
        location: ${env.VERTEX_AI_LOCATION:=global}
```

Additionally, you need to ensure your Google Application Credentials are mounted to the Lightspeed Core container and the `GOOGLE_APPLICATION_CREDENTIALS` environment variable is the path to the mount location.

To set this up with the provided `compose/compose.yaml`, set `GOOGLE_APPLICATION_CREDENTIALS_HOST_PATH` to the path on your host machine of a GCP service account JSON key (or your `gcloud auth application-default login` credentials file). The compose file mounts that file into the container and points `GOOGLE_APPLICATION_CREDENTIALS` at the mounted path for you — do not set `GOOGLE_APPLICATION_CREDENTIALS` to a host path yourself, since that path won't exist inside the container.

```env
VERTEX_AI_PROJECT=
VERTEX_AI_LOCATION=
GOOGLE_APPLICATION_CREDENTIALS_HOST_PATH=<path-on-your-host-to-a-gcp-service-account-json-key>
```

The service account (or `gcloud auth application-default login` credentials) needs the `Vertex AI User` role, and the Vertex AI API must be enabled on `VERTEX_AI_PROJECT`.

Provider details: [Llama Stack (OGX) Vertex AI docs](https://ogx-ai.github.io/docs/providers/inference/remote_vertexai).

For GitOps/production, [generate-gitops-manifests.sh](../scripts/generate-gitops-manifests.sh) uncomments this stub and adds `allowed_models`. If the production shape changes, update the tracked stub and/or `add_inference_allowed_models` in that script.

## Restricting Models (`allowed_models`)

Each of the providers above supports an `allowed_models` field to limit which models get registered with Llama Stack. This is most useful for `openai` and `vertexai`, since they auto-discover every model available to your account/project unless restricted.

To use it locally, add `allowed_models` under the provider's `extra` block in `lightspeed-core-configs/lightspeed-stack.local.yaml`. For GitOps/production, [generate-gitops-manifests.sh](../scripts/generate-gitops-manifests.sh) overlays production `allowed_models` automatically for `openai` and `vertexai`.

Open AI example:
```yaml
inference:
  providers:
    - type: openai
      id: <your-unique-id>
      api_key_env: OPENAI_API_KEY
      extra:
        allowed_models:
          - gpt-4o
          - gpt-4o-mini
```

If `allowed_models` is omitted, all models the provider can see are registered.

## Full Example

The example below illustrates a local `lightspeed-stack.local.yaml` with providers uncommented. Ollama is optional and shown here for illustration only.

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
    profile: /app-root/config.yaml
inference:
  providers:
    - type: sentence_transformers
    - type: openai
      id: openai
      api_key_env: OPENAI_API_KEY
      extra:
        allowed_models:
          - gpt-4o
          - gpt-4o-mini
    - type: vllm
      id: vllm-team
      api_key_env: VLLM_API_KEY
      extra:
        base_url: ${env.VLLM_URL:=}
        max_tokens: ${env.VLLM_MAX_TOKENS:=4096}
        network:
          tls:
            verify: ${env.VLLM_TLS_VERIFY:=true}
    - type: vllm
      id: ollama
      extra:
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