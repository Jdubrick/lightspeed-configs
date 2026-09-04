# Release regression CI

The release regression workflow runs the regression runner against a release
branch only when the `lightspeed-core.image` value in `images.yaml` changes.
It does not run for `main` or for pull requests opened from forks.

The workflow uses the release branch's Compose stack and adds the following CI
services through `compose.regression.yaml`:

- `test-mcp-server` for MCP tool-call coverage
- `regression-runner` using
  `quay.io/redhat-ai-dev/lightspeed-regression-runner:release-1.10-latest`
- shared feedback and result directories

The workflow reads the target `lightspeed-core` image from the PR's
`images.yaml` and passes it explicitly to the CI Compose overlay. Provider
credentials and settings are passed directly to the `lightspeed-core`
service's environment block from GitHub Actions secrets and variables.

For local execution on a release checkout:

```sh
bash .ci/prepare-regression.sh
make get-rag CONTAINER_ENGINE=docker
docker compose \
  --env-file env/default-values.env \
  -f compose/compose.yaml \
  -f .ci/compose.regression.yaml \
  up --abort-on-container-exit --exit-code-from regression-runner
```

For local execution, export the provider credentials and settings required by
the Compose overlay before running the command. The generated `.ci/work/` and
`.ci/artifacts/` paths are ignored by Git.
