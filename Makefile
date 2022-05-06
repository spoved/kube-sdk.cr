BUILD_COMMIT := $(shell git rev-parse --short HEAD 2> /dev/null)
K8S_VERSION="v1.22"

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z \-_0-9]+:.*?## / {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

spec: ## Run tests
	@k3d cluster create -c ./spec/files/k3d/${K8S_VERSION}.yml
	@crystal spec --error-trace --exclude-warnings /usr/local/Cellar/crystal --exclude-warnings ./lib/ -Dk8s_${K8S_VERSION}
	@k3d cluster delete k3d-cluster-test

build: ## Build the binary
	@shards build -Dk8s_${K8S_VERSION}

docs: ## Generate docs
	@crystal docs -Dk8s_${K8S_VERSION} --error-trace -s -p -t ./src/kube-sdk.cr ./lib/k8s/src/k8s.cr ./examples/plex-controller/crd.cr

.PHONY: help spec build docs