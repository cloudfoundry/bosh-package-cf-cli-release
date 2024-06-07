# Architecture

## Workflow

- Manually create a release by clicking a button to execute the workflow action
- Download CLI binaries from CLAW and compare against the current bosh release manifest
- Configure Bosh S3 blobs backend
- For each difference between bosh manifest and CLAW:
  - Add the blob
  - Upload the blob
  - Create git commit for the new blob
  - Push to github
- Create dev bosh release, which is exported to a .tgz
- Create a bosh deployment in shepherd that includes the new dev release
- Run the tests in shepherd using the new dev release
- Calculate new version number for this pending release
  - Point of question — how to calculate this semver id? Maybe changesets? How could we configure changesets to find the correct "current" version of the bosh release?
- Create a final bosh release with that version
  - This does an S3 push
  - It also makes a git commit
- Create git tag with that version
- Push to github
- Create github release with this tag

## Improvements

- Make this more transactional.
  - Can we do the github and S3 pushes very closely together, at the very end?
  - Can we make them succeed or fail together?
  - Maybe we push to a dev bucket before tests, then — only on green tests — push everything to a prod bucket?
- Autogenerate release notes from release notes on CLI.
  - Can changesets help here too?
