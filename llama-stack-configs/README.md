# Llama Stack Configuration Files

This directory stores the Llama Stack run config for the single active release tracked on `main`.

- `run.yaml` is the unified config. Safety guards are conditionally enabled via the `ENABLE_SAFETY` environment variable (see [CONTRIBUTING.md](../docs/CONTRIBUTING.md#configuring-safety-guards)).

Historical release-specific configs are maintained in release branches and tags.