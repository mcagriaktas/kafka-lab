import jenkins.model.*
import hudson.util.*
import jenkins.install.*
import hudson.model.*
import java.util.logging.Logger

def logger = Logger.getLogger("")
def instance = Jenkins.getInstance()
def pluginManager = instance.getPluginManager()
def updateCenter = instance.getUpdateCenter()

def plugins = [
  "pipeline-stage-view",
  "workflow-aggregator",
  "job-dsl",
  "ansicolor",
  "pipeline-utility-steps",
  "prometheus",
  "metrics",
  "metrics-diskusage",
  "build-monitor-plugin",
  "cloudbees-disk-usage-simple",
  "disk-usage",
]

logger.info("--- Installing plugins ---")
updateCenter.updateAllSites()

def failedPlugins = []
plugins.each { plugin ->
  logger.info("Installing ${plugin}")
  if (!pluginManager.getPlugin(plugin)) {
    try {
      def pluginInstallation = updateCenter.getPlugin(plugin).deploy(true)
      pluginInstallation.get()
    } catch (Exception e) {
      logger.severe("Failed to install ${plugin}: ${e.message}")
      failedPlugins.add(plugin)
    }
  }
}

def markerFile = new File(instance.rootDir, ".plugins-installed")
markerFile.text = "Plugins installation completed at ${new Date()}\n"
if (!failedPlugins.isEmpty()) {
  markerFile.append("Failed plugins: ${failedPlugins.join(', ')}\n")
}

instance.save()
logger.info("--- Plugins installation completed ---")