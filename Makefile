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
	find . -name '.git' -prune -o -type f -print | entr -c \
		act \
			--actor "${GITHUB_USER}" \
			--secret GITHUB_TOKEN="${GITHUB_TOKEN}" \
			--workflows .github/workflows/create-bosh-release.yml \
			--job bosh_release_create_candidate

hijack-act:
	./ci/scripts/hijack-act.sh
