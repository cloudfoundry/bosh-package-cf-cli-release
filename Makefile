ifndef GITHUB_USER
	$(error GITHUB_USER is not set)
endif

create-bosh-release:
	act \
		--actor "${GITHUB_USER}" \
		--secret GITHUB_TOKEN="${GITHUB_TOKEN}" \
		--workflows .github/workflows/create-bosh-release.yml

ensure-ci-image:
	act \
		--actor "${GITHUB_USER}" \
		--secret GITHUB_TOKEN="${GITHUB_TOKEN}" \
		--workflows .github/workflows/ensure-ci-image.yml

lint:
	act \
		--actor "${GITHUB_USER}" \
		--secret GITHUB_TOKEN="${GITHUB_TOKEN}" \
		--workflows .github/workflows/lint.yml

run:
	@echo "Running make with arguments after -- : $(MAKECMDGOALS)"

	# find . -name '.git' -prune -o -type f -print | entr -c \
		act \
			--actor "${GITHUB_USER}" \
			--secret GITHUB_TOKEN="${GITHUB_TOKEN}" \
			--workflows .github/workflows/create-bosh-release.yml \
			--secret-file .secrets \
			--var-file    .env \
			--job bosh_release_create_candidate \
			--rm \
			--artifact-server-path /tmp/artifacts \
			$(MAKECMDGOALS)

hijack-act:
	./ci/scripts/hijack-act.sh

bosh:
	./ci/scripts/bosh-connect.sh