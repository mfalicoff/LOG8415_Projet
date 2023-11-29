SHELL: /bin/bash

push-proxy:
	@echo "Pushing proxy image to CR..."
	@cd ./proxy && \
		docker buildx create --use  && \
		docker buildx build --platform linux/amd64,linux/arm64 --push -t mazil007/mf-proxy:latest .
	@echo "Redeploying proxy..."
	@cd ../terraform && \
		make configure-cluster-proxy