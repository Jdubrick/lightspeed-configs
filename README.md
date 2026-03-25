# Lightspeed Configs

[![Apache2.0 License](https://img.shields.io/badge/license-Apache2.0-brightgreen.svg)](LICENSE)
[![Llama Stack Version](https://img.shields.io/badge/Llama%20Stack-0.5.2-blue)]()
[![RHDH Release](https://img.shields.io/badge/RHDH%20Release-1.10-blueviolet)]()

## Versions

See [images.yaml](./images.yaml) for current sprint images and versions.

`main` tracks one active release at a time. Historical releases are preserved in `rhdh-x.x` branches and Git tags.

## Architecture

The configuration in this repository is designed to run with [Lightspeed Core](https://github.com/lightspeed-core/lightspeed-stack) in **library mode**. In this mode, Lightspeed Core (LCORE) and Llama Stack run in the same container and process boundary, so these configs target a single combined runtime rather than separate services.

## Release Process

Release and hotfix workflow is documented in [docs/RELEASE_PROCESS.md](./docs/RELEASE_PROCESS.md).

## Provider Configuration

Provider-specific setup and environment variable details live in [docs/PROVIDERS.md](./docs/PROVIDERS.md).

## Contributing

See [docs/CONTRIBUTING.md](./docs/CONTRIBUTING.md) for local development setup, running services, syncing configs, and troubleshooting.
