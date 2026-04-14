.PHONY: l10n l10n-add l10n-check

## Regenerate Dart localization files from .arb sources.
l10n:
	flutter gen-l10n

## Add a new localization key to both .arb files and regenerate.
## Usage: make l10n-add KEY=myKey EN="My value" ES="Mi valor"
l10n-add:
	@if [ -z "$(KEY)" ] || [ -z "$(EN)" ] || [ -z "$(ES)" ]; then \
		echo "Usage: make l10n-add KEY=myKey EN=\"My value\" ES=\"Mi valor\""; \
		exit 1; \
	fi
	./scripts/add_l10n.sh "$(KEY)" "$(EN)" "$(ES)"

## Verify that every key in app_en.arb exists in app_es.arb.
l10n-check:
	dart scripts/check_l10n.dart
