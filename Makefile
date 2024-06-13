GH_ARGS=--repo cloudfoundry/bosh-package-cf-cli-release
GITHUB_TOKEN:=$(shell gh auth token || (gh auth login --scopes "write:packages, workflow" && gh auth token))
GITHUB_USER:=$(gh api user | jq -r '.login')
PAGER=cat

repo-context-setup: repo-context-set-vars repo-context-set-secrets

repo-context-cleanup: repo-context-cleanup-vars repo-context-cleanup-secrets

repo-context-cleanup-vars:
	gh variable ${GH_ARGS} list --json name --jq '.[].name' \
	| xargs -n1 echo gh variable ${GH_ARGS} delete

repo-context-cleanup-secrets:
	gh secret ${GH_ARGS} list --json name --jq '.[].name' \
	| xargs -n1 echo gh secret ${GH_ARGS} delete

repo-context-set-vars:
	gh variable ${GH_ARGS} list
	gh variable ${GH_ARGS} set -f .vars
	gh variable ${GH_ARGS} list

repo-context-set-secrets:
	gh secret ${GH_ARGS} list
	gh secret ${GH_ARGS} set  -f .secrets
	gh secret ${GH_ARGS} list

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
			--var-file    .vars \
			--job create_bosh_release \
			--rm \
			--artifact-server-path /tmp/artifacts \
			$(MAKECMDGOALS)

hijack-act:
	./ci/scripts/hijack-act.sh

bosh:
	./ci/scripts/bosh-connect.sh
