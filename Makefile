.PHONY: cloud
cloud: scripts/deploy-cloud
	./$<


.PHONY: format
format: $(shell find . -name '*.jsonnet')
	jsonnetfmt -i $^
