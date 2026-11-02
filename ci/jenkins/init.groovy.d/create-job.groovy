import hudson.plugins.git.BranchSpec
import hudson.plugins.git.GitSCM
import hudson.plugins.git.UserRemoteConfig
import hudson.model.BooleanParameterDefinition
import hudson.model.ParametersDefinitionProperty
import hudson.model.StringParameterDefinition
import jenkins.model.Jenkins
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import org.jenkinsci.plugins.workflow.job.WorkflowJob

def jenkins = Jenkins.get()
def job = jenkins.getItem('vendor-portal-ci')
if (job == null) {
  job = jenkins.createProject(WorkflowJob, 'vendor-portal-ci')
}

def remote = new UserRemoteConfig('file:///home/areyy/.cache/vendor-portal-ci/source', null, null, null)
def scm = new GitSCM([remote], [new BranchSpec('*/develop')], false, [], null, null, [])
def flow = new CpsScmFlowDefinition(scm, 'Jenkinsfile')
flow.setLightweight(false)
job.setDefinition(flow)
job.addProperty(new ParametersDefinitionProperty([
  new BooleanParameterDefinition('PUBLISH_IMAGES', false, 'Publish images to the configured local or remote registry.'),
  new StringParameterDefinition('REGISTRY_HOST', '', 'Optional registry host.'),
  new StringParameterDefinition('REGISTRY_NAMESPACE', '', 'Registry namespace or Docker Hub username.'),
  new StringParameterDefinition('REGISTRY_CREDENTIALS_ID', '', 'Optional registry credential ID.'),
  new StringParameterDefinition('DEPLOY_TARGET', '', 'Optional Ansible inventory group.')
]))
job.setConcurrentBuild(false)
job.save()
jenkins.save()
