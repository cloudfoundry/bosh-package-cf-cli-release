ensure-ci-image:
	act --actor "${GITHUB_USER}" --secret GITHUB_TOKEN="${GITHUB_TOKEN}" -W .github/workflows/ensure-ci-image.yml

lint:
	act -W .github/workflows/lint.yml

run:
	ls .github/**/* | entr -c \
	  act --secret      GITHUB_TOKEN="$(gh auth token)" \
	      --var-file    .github/.vars \
	      --secret-file .github/.secret \
	      --workflows   .github/workflows/create-bosh-release.yml \
	      --job         bosh_release_create_candidate
