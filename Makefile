cloud-targets := $(notdir $(basename $(wildcard deployment-manager/*)))

.PHONY: cloud
cloud: $(cloud-targets)


.PHONY: $(cloud-targets)
$(cloud-targets): scripts/deploy-cloud
	./$< $@


.PHONY: format
format: $(shell find . -name '*.jsonnet')
	jsonnetfmt -i $^
