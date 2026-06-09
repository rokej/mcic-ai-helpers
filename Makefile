.PHONY: help chmod-scripts

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

chmod-scripts: ## Make runner scripts executable
	chmod +x scripts/*.sh scripts/lib/*.sh
	chmod +x plugins/utils/scripts/check_replied.py
