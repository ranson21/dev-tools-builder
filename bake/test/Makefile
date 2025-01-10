.PHONY: all versions make_version git_version curl_version wget_version unzip_version \
        python_version pip_version node_version npm_version poetry_version \
        terraform_version terragrunt_version gcloud_version

all: versions

# Show all tool versions
versions: make_version git_version curl_version wget_version unzip_version \
         python_version pip_version node_version npm_version poetry_version \
         terraform_version terragrunt_version gcloud_version

make_version:
	@echo "Make version:"
	@make --version | head -n 1

git_version:
	@echo "Git version:"
	@git --version

curl_version:
	@echo "Curl version:"
	@curl --version | head -n 1

wget_version:
	@echo "Wget version:"
	@wget --version | head -n 1

unzip_version:
	@echo "Unzip version:"
	@unzip -v | head -n 1

python_version:
	@echo "Python version:"
	@python3 --version

pip_version:
	@echo "Pip version:"
	@pip3 --version

node_version:
	@echo "Node version:"
	@node --version

npm_version:
	@echo "NPM version:"
	@npm --version

poetry_version:
	@echo "Poetry version:"
	@poetry --version

terraform_version:
	@echo "Terraform version:"
	@terraform --version

terragrunt_version:
	@echo "Terragrunt version:"
	@terragrunt --version

gcloud_version:
	@echo "Google Cloud SDK version:"
	@gcloud --version | head -n 1

help:
	@echo "Available targets:"
	@echo "  versions           - Show all tool versions"
	@echo "  make_version      - Show Make version"
	@echo "  git_version       - Show Git version"
	@echo "  curl_version      - Show Curl version"
	@echo "  wget_version      - Show Wget version"
	@echo "  unzip_version     - Show Unzip version"
	@echo "  python_version    - Show Python version"
	@echo "  pip_version       - Show Pip version"
	@echo "  node_version      - Show Node.js version"
	@echo "  npm_version       - Show NPM version"
	@echo "  poetry_version    - Show Poetry version"
	@echo "  terraform_version - Show Terraform version"
	@echo "  terragrunt_version - Show Terragrunt version"
	@echo "  gcloud_version    - Show Google Cloud SDK version"