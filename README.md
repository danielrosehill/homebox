# Homebox Custom Docker Image

This is a custom build of Homebox that includes additional features not yet merged into the main project.

## Features

- Fuzzy search functionality
- Asset ID lookup (coming soon)

## Quick Start

```bash
docker run -d \
  --name homebox \
  -p 7745:7745 \
  -v homebox-data:/data \
  danielrosehill/homebox:fuzzy-search
```

For more detailed instructions, see the [docker/custom-fuzzy-search/README.md](docker/custom-fuzzy-search/README.md) file.

## Maintenance

This repository is a fork of [Homebox](https://github.com/sysadminsmedia/homebox) with custom features and Docker images.

### Adding New Features

1. Create a feature branch from the main Homebox repository
2. Develop and test your feature
3. Use the integration scripts to add the feature to your custom Docker image:

```bash
cd docker/custom-fuzzy-search/scripts
./integrate-feature.sh your-feature-branch
```

### Building and Testing

```bash
cd docker/custom-fuzzy-search/scripts
./build-and-test.sh
```

### Updating Your Container

```bash
docker pull danielrosehill/homebox:fuzzy-search
docker-compose down
docker-compose up -d
