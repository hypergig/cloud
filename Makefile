cloud-targets := $(notdir $(basename $(wildcard deployment-manager/*)))

.PHONY: cloud
cloud: $(cloud-targets)


.PHONY: $(cloud-targets)
$(cloud-targets): scripts/deploy-cloud
	./$< $@


.PHONY: format
format: $(shell find . -name '*.jsonnet')
	jsonnetfmt -i $^


.PHONY: apply
apply:
	jsonnet -y kubernetes/manifest.jsonnet | kubectl apply -f -
	jsonnet -y kubernetes/deployments.jsonnet | kubectl rollout status -w -f -


.PHONY: delete
delete:
	jsonnet -y kubernetes/manifest.jsonnet | kubectl delete -f - --wait=false ||:
