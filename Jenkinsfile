pipeline {
  agent any
  options { timestamps(); disableConcurrentBuilds(); buildDiscarder(logRotator(numToKeepStr: '20')) }
  environment {
    TAG = "${env.BUILD_NUMBER}"
  }
  triggers { pollSCM('H/5 * * * *') }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Backend build and unit tests') { steps { dir('backend') { sh 'mvn -B verify' } } }
    stage('Frontend dependency install and build') { steps { dir('frontend') { sh 'npm ci'; sh 'npm run build' } } }
    stage('Selenium end-to-end') {
      steps {
        withCredentials([
          string(credentialsId: 'portal-admin-password', variable: 'ADMIN_PASSWORD'),
          string(credentialsId: 'portal-db-password', variable: 'DB_PASSWORD'),
          string(credentialsId: 'portal-mysql-root-password', variable: 'MYSQL_ROOT_PASSWORD')
        ]) {
          script {
            try {
              sh 'docker compose up --build -d'
              sh 'for i in $(seq 1 36); do curl -fsS http://localhost:8088/actuator/health && exit 0; sleep 5; done; exit 1'
              dir('backend') {
              withEnv(['E2E_BASE_URL=http://localhost:8088']) {
                  sh 'mvn -B -Pselenium verify'
                }
              }
            } finally {
              sh(script: 'docker compose down -v', returnStatus: true)
            }
          }
        }
      }
    }
    stage('Package') { steps { archiveArtifacts artifacts: 'backend/target/*.jar,frontend/dist/**', fingerprint: true } }
    stage('Docker build and push') {
      when { branch 'main' }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DH_USER', passwordVariable: 'DH_TOKEN')]) {
          sh 'echo "$DH_TOKEN" | docker login -u "$DH_USER" --password-stdin'
          sh 'docker build -f Dockerfile.backend -t "$DH_USER/vendor-purchase-order-portal-backend:$TAG" .'
          sh 'docker build -f Dockerfile.frontend -t "$DH_USER/vendor-purchase-order-portal-frontend:$TAG" .'
          sh 'docker push "$DH_USER/vendor-purchase-order-portal-backend:$TAG"'
          sh 'docker push "$DH_USER/vendor-purchase-order-portal-frontend:$TAG"'
        }
      }
    }
    stage('Deploy and health check') {
      when { allOf { branch 'main'; expression { return env.DEPLOY_TARGET != null && env.DEPLOY_TARGET != '' } } }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DH_USER', passwordVariable: 'DH_TOKEN')]) {
          sh 'ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/deploy.yml --extra-vars "release_tag=$TAG registry_namespace=$DH_USER"'
        }
      }
    }
  }
  post {
    always {
      junit testResults: 'backend/target/surefire-reports/*.xml,backend/target/failsafe-reports/*.xml', allowEmptyResults: true
      archiveArtifacts artifacts: 'backend/target/selenium-screenshots/*.png', allowEmptyArchive: true
    }
    success { echo "Build ${env.BUILD_NUMBER} completed." }
    failure { echo 'Build failed; deployment stages are gated on successful prior stages.' }
  }
}
