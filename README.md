<div align="center">

# 🛠️ Dev Tools Builder Image

A Packer-built Docker image with development tools, designed for Cloud Build pipelines.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

## 👋 Introduction

This repository contains Packer configurations to build a Docker image with common development tools. The image uses `make` as its entrypoint and is specifically designed for Cloud Build pipelines.

## ✨ Features

- Ubuntu 22.04 base image
- Pre-installed development tools:
  - build-essential
  - git
  - curl
  - wget
  - unzip
  - python3/pip
  - nodejs/npm
- Make-based command interface
- Cloud Build ready
- Customizable through Packer variables

## 🚀 Getting Started

### Prerequisites

- Packer >= 1.7.0
- Docker

### Building and Testing

The project includes a Makefile with the following targets:

```bash
# Initialize Packer plugins
make init

# Validate Packer configuration
make validate

# Build the Docker image
make build

# Test the built image
make test

# Clean up build artifacts
make clean
```

### Customizing the Build

You can customize the build by modifying the variables in `bake/variables.pkr.hcl` or by passing them during build:

```bash
cd bake
packer build -var="base_image=ubuntu:20.04" -var="image_name=custom-dev-tools" .
```

## 📁 Repository Structure

```
.
├── bake/
│   ├── build.pkr.hcl       # Main Packer configuration
│   ├── variables.pkr.hcl   # Packer variables
│   └── test/
│       └── Makefile        # Container test Makefile
├── Makefile                # Build and test automation
├── LICENSE                 # MIT License
└── README.md               # This file
```

## 🔧 Usage in Cloud Build

Example usage in `cloudbuild.yaml`:
```yaml
steps:
  - name: 'my-image'
    entrypoint: make
    args: ['build']
    id: 'build'
```

## 👥 Author

**Abby Ranson**  
GitHub: [@ranson21](https://github.com/ranson21)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request