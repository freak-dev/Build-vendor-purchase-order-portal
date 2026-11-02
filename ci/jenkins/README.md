# Local Jenkins and registry demonstration

This harness runs Jenkins and a Docker Registry v2 inside the installed Ubuntu WSL distribution. Jenkins runs the checked-in pipeline against the local `develop` branch and publishes both application images to the local registry. It is a repeatable local CI demonstration; it does not create a GitHub repository or publish to Docker Hub.

## Start

From Windows PowerShell, run `scripts/run-local-ci.ps1`. The script builds a Jenkins image with Docker CLI/Compose and required Pipeline plugins, then starts Jenkins on `http://localhost:8081` and Registry v2 on `localhost:5000`. The test credentials and Jenkins administrator password are stored in WSL at `~/.config/vendor-portal/.env` with mode 0600. Do not copy that file into Git.

The Jenkins user is `admin`; retrieve its password locally from the WSL secret file when opening the UI. Jenkins installs credentials for the application admin and database bootstrap from that same file. The pipeline uses an isolated Compose project and ephemeral database volume for every build, so cleanup cannot remove the developer stack.

## Run the job

The job name is `vendor-portal-ci`. Trigger it from the Jenkins page or use **Build Now**. It checks out the local `develop` branch, runs Maven unit tests and the frontend build in versioned Docker images, starts an isolated Compose stack, runs Selenium, archives reports, builds tagged application images, and pushes them to the local registry. Successful image references are saved in the Jenkins build as `published-images.txt`.

Local tags use the Jenkins build number, for example `localhost:5000/vendor/vendor-purchase-order-portal-backend:<build>` and the corresponding frontend image. Inspect the registry catalog with `curl http://localhost:5000/v2/_catalog` inside WSL.

## Stop and reset

The services use restart policies and remain in WSL for review. Stop them with `wsl -d Ubuntu -u root -- docker stop vendor-portal-jenkins vendor-portal-registry`. Their named volumes preserve Jenkins configuration and registry artifacts. Remove those volumes only when intentionally resetting the local demonstration environment.

The Jenkins pipeline retains the Docker Hub credential path for a real release: configure `REGISTRY_HOST` empty, `REGISTRY_NAMESPACE` to the Docker Hub namespace, and `REGISTRY_CREDENTIALS_ID=dockerhub` in Jenkins. External deployment remains gated on `DEPLOY_TARGET`, an SSH credential named `deploy-ssh-key`, a real inventory, and target-side secrets. None of those external services or credentials are assumed by this local run.
