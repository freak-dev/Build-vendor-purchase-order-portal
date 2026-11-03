pipeline {
  agent any
  options {
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }
  environment {
    TAG = "${env.BUILD_NUMBER}"
  }
  parameters {
    booleanParam(name: 'PUBLISH_IMAGES', defaultValue: false, description: 'Publish tagged images after all tests pass.')
    string(name: 'REGISTRY_HOST', defaultValue: '', description: 'Optional registry host, such as localhost:5000.')
    string(name: 'REGISTRY_NAMESPACE', defaultValue: '', description: 'Registry namespace or Docker Hub username.')
    string(name: 'REGISTRY_CREDENTIALS_ID', defaultValue: '', description: 'Optional Jenkins username/password credential ID.')
    string(name: 'DEPLOY_TARGET', defaultValue: '', description: 'Optional configured Ansible target group.')
  }
  triggers { pollSCM('H/5 * * * *') }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Backend build and unit tests') {
      steps {
        sh '''docker run --rm \
          --user "$(id -u):$(id -g)" -e HOME=/tmp -e MAVEN_OPTS=-Duser.home=/tmp \
          -v "$WORKSPACE/backend:/workspace" -w /workspace \
          maven:3.9-eclipse-temurin-21 mvn -B verify'''
      }
    }
    stage('Frontend dependency install and build') {
      steps {
        sh '''docker run --rm \
          --user "$(id -u):$(id -g)" -e HOME=/tmp -e npm_config_cache=/tmp/.npm \
          -v "$WORKSPACE/frontend:/workspace" -w /workspace \
          node:24-alpine sh -lc 'npm ci --no-audit --no-fund && npm run build' '''
      }
    }
    stage('Selenium end-to-end') {
      steps {
        withCredentials([
          string(credentialsId: 'portal-admin-password', variable: 'ADMIN_PASSWORD'),
          string(credentialsId: 'portal-db-password', variable: 'DB_PASSWORD'),
          string(credentialsId: 'portal-mysql-root-password', variable: 'MYSQL_ROOT_PASSWORD')
        ]) {
          script {
            def ciProject = "vendor-ci-${env.BUILD_NUMBER}"
            def ciPort = 18000 + (env.BUILD_NUMBER.toInteger() % 10000)
            def selenium = "${ciProject}-selenium"
            withEnv([
              "COMPOSE_PROJECT_NAME=${ciProject}",
              "HTTP_PORT=${ciPort}",
              "CI_SELENIUM=${selenium}"
            ]) {
              try {
                sh 'docker compose up --build -d'
                sh '''i=1
                  while [ "$i" -le 36 ]; do
                    if curl -fsS "http://127.0.0.1:$HTTP_PORT/actuator/health"; then exit 0; fi
                    sleep 5
                    i=$((i+1))
                  done
                  exit 1'''
                sh '''docker run -d --name "$CI_SELENIUM" --network "${COMPOSE_PROJECT_NAME}_default" --shm-size=2g -e SE_NODE_MAX_SESSIONS=1 selenium/standalone-chrome:latest'''
                sh '''ready=false
                  for i in $(seq 1 60); do
                    if docker run --rm --network "${COMPOSE_PROJECT_NAME}_default" curlimages/curl:8.12.1 -fsS "http://$CI_SELENIUM:4444/status" 2>/dev/null | grep -Eq '"ready"[[:space:]]*:[[:space:]]*true'; then ready=true; break; fi
                    sleep 2
                  done
                  [ "$ready" = true ] || { echo 'Selenium did not become ready'; exit 1; }'''
                sh '''docker run --rm --network "${COMPOSE_PROJECT_NAME}_default" \
                  --user "$(id -u):$(id -g)" -e HOME=/tmp -e MAVEN_OPTS=-Duser.home=/tmp \
                  -v "$WORKSPACE/backend:/workspace" -w /workspace \
                  -e E2E_USER=admin -e E2E_PASSWORD="$ADMIN_PASSWORD" \
                  -e E2E_BASE_URL=http://frontend \
                  -e REMOTE_WEBDRIVER_URL="http://$CI_SELENIUM:4444/wd/hub" \
                  maven:3.9-eclipse-temurin-21 mvn -B -Pselenium verify'''
              } finally {
                sh(script: "docker rm -f ${selenium}", returnStatus: true)
                sh(script: 'docker compose down -v --remove-orphans', returnStatus: true)
              }
            }
          }
        }
      }
    }
    stage('Package') {
      steps {
        archiveArtifacts artifacts: 'backend/target/*.jar,frontend/dist/**', fingerprint: true
      }
    }
    stage('Docker build and publish') {
      when {
        anyOf {
          branch 'main'
          expression { return params.PUBLISH_IMAGES }
        }
      }
      steps {
        script {
          def registryHost = params.REGISTRY_HOST?.trim() ?: ''
          def namespace = params.REGISTRY_NAMESPACE?.trim() ?: env.DOCKERHUB_NAMESPACE
          if (!namespace) { error('Set REGISTRY_NAMESPACE (or DOCKERHUB_NAMESPACE) before publishing images.') }
          def prefix = registryHost ? "${registryHost}/${namespace}" : namespace
          def backendImage = "${prefix}/vendor-purchase-order-portal-backend:${env.TAG}"
          def frontendImage = "${prefix}/vendor-purchase-order-portal-frontend:${env.TAG}"
          def publish = {
            sh "docker build -f Dockerfile.backend -t ${backendImage} ."
            sh "docker build -f Dockerfile.frontend -t ${frontendImage} ."
            sh "docker push ${backendImage}"
            sh "docker push ${frontendImage}"
          }
          if (params.REGISTRY_CREDENTIALS_ID?.trim()) {
            withCredentials([usernamePassword(credentialsId: params.REGISTRY_CREDENTIALS_ID.trim(), usernameVariable: 'REGISTRY_USER', passwordVariable: 'REGISTRY_TOKEN')]) {
              sh "echo \"\$REGISTRY_TOKEN\" | docker login ${registryHost ?: 'https://index.docker.io/v1/'} -u \"\$REGISTRY_USER\" --password-stdin"
              try { publish() } finally { sh 'docker logout || true' }
            }
          } else {
            publish()
          }
          writeFile file: 'published-images.txt', text: "${backendImage}\n${frontendImage}\n"
          archiveArtifacts artifacts: 'published-images.txt', fingerprint: true
        }
      }
    }
    stage('Deploy and health check') {
      when {
        allOf {
          anyOf {
            branch 'main'
            expression { return params.DEPLOY_TARGET?.trim() }
          }
          expression { return params.DEPLOY_TARGET?.trim() }
        }
      }
      steps {
        sh 'ansible-galaxy collection install -r ansible/requirements.yml'
        withCredentials([file(credentialsId: 'deploy-become-password-file', variable: 'ANSIBLE_BECOME_PASSWORD_FILE')]) {
          sshagent(credentials: ['deploy-ssh-key']) {
            sh 'ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/deploy.yml --limit "$DEPLOY_TARGET" --become-password-file "$ANSIBLE_BECOME_PASSWORD_FILE" --extra-vars "release_tag=$TAG registry_namespace=$REGISTRY_NAMESPACE"'
          }
        }
      }
    }
  }
  post {
    always {
      junit testResults: 'backend/target/surefire-reports/*.xml,backend/target/failsafe-reports/*.xml', allowEmptyResults: true
      script {
        def screenshots = sh(
          script: 'find backend/target/selenium-screenshots -maxdepth 1 -name "*.png" -print -quit 2>/dev/null || true',
          returnStdout: true
        ).trim()
        if (screenshots) {
          archiveArtifacts artifacts: 'backend/target/selenium-screenshots/*.png', fingerprint: true
        }
      }
    }
    success { echo "Build ${env.BUILD_NUMBER} completed." }
    failure { echo 'Build failed; image publication and deployment are gated on successful prior stages.' }
  }
}
