run:
	ls .github/**/* | entr -c \
	  act --secret      GITHUB_TOKEN="$(gh auth token)" \
	      --var-file    .github/.vars \
	      --secret-file .github/.secret \
	      --workflows   .github/workflows/create-bosh-release.yml \
	      --job         bosh_release_create_candidate
