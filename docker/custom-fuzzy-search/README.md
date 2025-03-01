# Homebox with Fuzzy Search

This is a custom build of Homebox that includes the fuzzy search feature.

## Features

- All standard Homebox features
- Enhanced search functionality with fuzzy matching
- Improved multi-word search capabilities
- Phonetic matching for similar-sounding words

## Using the Docker Image

### Quick Start

```bash
docker run -d \
  --name homebox \
  -p 7745:7745 \
  -v homebox-data:/data \
  danielrosehill/homebox:fuzzy-search
```

### Using Docker Compose

1. Download the `docker-compose.yml` file:

```bash
mkdir -p homebox-fuzzy && cd homebox-fuzzy
wget https://raw.githubusercontent.com/danielrosehill/homebox/custom-docker-image/docker/custom-fuzzy-search/docker-compose.yml
```

2. Start the container:

```bash
docker-compose up -d
```

## Configuration

The container uses the following environment variables:

- `HBOX_MODE`: Set to `production` by default
- `HBOX_STORAGE_DATA`: Set to `/data/` by default
- `HBOX_STORAGE_SQLITE_URL`: Set to `/data/homebox.db?_pragma=busy_timeout=2000&_pragma=journal_mode=WAL&_fk=1` by default

You can override these by adding `-e VARIABLE=VALUE` to your docker run command or by adding an environment section to your docker-compose file.

## Data Persistence

The container stores all data in the `/data` volume. Make sure to mount this volume to persist your data between container restarts.

## Updating

To update to the latest version:

```bash
docker pull danielrosehill/homebox:fuzzy-search
docker-compose down
docker-compose up -d
```

## Maintenance Scripts

This repository includes several scripts to help maintain your custom Docker image:

### Integrating a New Feature

To integrate a new feature branch into your custom Docker image:

```bash
cd docker/custom-fuzzy-search/scripts
./integrate-feature.sh feature-branch-name
```

For example, to integrate the asset ID lookup feature:

```bash
./integrate-feature.sh asset-id-lookup
```

### Updating All Features

To update your custom Docker image with all available features:

```bash
cd docker/custom-fuzzy-search/scripts
./update-all-features.sh
```

### Building and Testing Locally

To build and test your custom Docker image locally:

```bash
cd docker/custom-fuzzy-search/scripts
./build-and-test.sh [tag]
```

The default tag is "local-test" if not specified.

## Building the Image Yourself

If you want to build the image yourself:

```bash
git clone https://github.com/danielrosehill/homebox.git
cd homebox
git checkout custom-docker-image
docker build -f docker/custom-fuzzy-search/Dockerfile -t yourusername/homebox:fuzzy-search .
