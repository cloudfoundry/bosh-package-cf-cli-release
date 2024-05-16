run:
	ls .github/**/* | entr -c \
	  act -s GITHUB_TOKEN="$(gh auth token)" \
		    --var-file .github/.vars \
				--secret-file .github/.secret \
		    -j bosh_release_create_candidate