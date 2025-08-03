import jenkins.model.*
import java.util.logging.Logger
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

def logger = Logger.getLogger("main-init")
def jenkins = Jenkins.getInstance()

logger.info("Setting up basic security...")
evaluate(new File(jenkins.rootDir, "groovys_base/basic-security.groovy"))

logger.info("Installing required plugins...")
evaluate(new File(jenkins.rootDir, "groovys_base/install-plugins.groovy"))

sleep(1000)

logger.info("Creating Kafka Topic Manager job...")
evaluate(new File(jenkins.rootDir, "groovys/create-kafka-topic-manager.groovy"))

def markerFile = new File(jenkins.rootDir, ".first-init-complete")
markerFile.text = "First initialization completed at ${new Date()}\n"

logger.info("Jobs created successfully. Waiting before restart...")
sleep(3000)

if (!new File(jenkins.rootDir, ".jenkins-restarted").exists()) {
    logger.info("Safely restarting Jenkins to activate plugins...")
    
    def restartMarker = new File(jenkins.rootDir, ".jenkins-restarted")
    restartMarker.text = "Jenkins restarted at ${new Date()}\n"
    
    Thread.start {
        sleep(1000)
        jenkins.safeRestart()
    }
} else {
    logger.info("Jenkins has already been restarted. Skipping restart.")
}

logger.info("Initialization process completed successfully.")