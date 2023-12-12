SHELL: /bin/bash

.PHONY: proxy trusted_host gatekeeper push-all push-proxy push trusted_host gatekeeper

push-all:
	@echo "Pushing all images to CR..."
	@$(MAKE) push-proxy
	@$(MAKE) trusted_host

push-proxy:
	@echo "Pushing proxy image to CR..."
	@cd ./proxy && \
		docker buildx create --use  && \
		docker buildx build --platform linux/amd64,linux/arm64 --push -t mazil007/mf-proxy:latest .
	@echo "Redeploying proxy..."
	@cd ../terraform && \
		make configure-cluster-proxy

push trusted_host:
	@echo "Pushing trusted_host image to CR..."
	@cd ./trusted_host && \
		docker buildx create --use  && \
		docker buildx build --platform linux/amd64,linux/arm64 --push -t mazil007/mf-trusted_host:latest .
	@echo "Redeploying trusted_host..."
	@cd ../terraform && \
		make configure-cluster-trusted_host

push-gatekeeper:
	@echo "Pushing gatekeeper image to CR..."
	@cd ./gatekeeper && \
		docker buildx create --use  && \
		docker buildx build --platform linux/amd64,linux/arm64 --push -t mazil007/mf-gatekeeper:latest .
	@echo "Redeploying gatekeeper..."
	@cd ../terraform && \
		make configure-cluster-gatekeeper