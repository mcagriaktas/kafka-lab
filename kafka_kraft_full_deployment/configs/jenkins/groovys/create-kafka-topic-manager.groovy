import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition

def jenkins = Jenkins.getInstance()

def jobName = "Kafka-Topic-Manager"
def pipelineScript = '''
pipeline {
    agent any
    parameters {
        string(name: 'TOPIC_NAME', defaultValue: '', description: 'The name of the Kafka topic')
        choice(name: 'OPERATION', choices: ['create', 'delete', 'describe', 'list', 'alter'], description: 'Operation to perform')
        string(name: 'PARTITIONS', defaultValue: '12', description: 'Number of partitions (for create or alter)')
        string(name: 'REPLICATION_FACTOR', defaultValue: '3', description: 'Replication factor (for create)')
    }
    stages {
        stage('Manage Kafka Topic') {
            steps {
                sh """
                  /opt/jenkins/scripts/create-kafka-topic-manager.sh \
                    '${params.OPERATION}' \
                    '${params.TOPIC_NAME}' \
                    '${params.PARTITIONS}' \
                    '${params.REPLICATION_FACTOR}'
                """
            }
        }
    }
}
'''

def job = jenkins.getItemByFullName(jobName)
if (job == null) {
    job = jenkins.createProject(WorkflowJob.class, jobName)
}
job.setDefinition(new CpsFlowDefinition(pipelineScript, true))
jenkins.save()
