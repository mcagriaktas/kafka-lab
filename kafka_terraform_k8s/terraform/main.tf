##########################################################################################
######################################## NAMESPACE #######################################
##########################################################################################
resource "kubernetes_manifest" "kafka_namespace" {
  manifest = {
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = var.namespace
    }
  }
}

##########################################################################################
##################################### KAFKA-HEADLESS #####################################
##########################################################################################
resource "kubernetes_manifest" "kafka_headless_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "kafka-headless"
      namespace = var.namespace
    }
    spec = {
      selector = {
        app = "kafka"
      }
      clusterIP = "None"
      ports = [
        {
          name = "broker"
          port = 9092
        },
        {
          name = "controller"
          port = 9093
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.kafka_namespace]
}

##########################################################################################
######################################## BROKERS ########################################
##########################################################################################
resource "kubernetes_manifest" "kafka_statefulset" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "StatefulSet"
    metadata = {
      name      = "kafka"
      namespace = var.namespace
    }
    spec = {
      serviceName = "kafka-headless"
      replicas    = var.replicas
      selector = {
        matchLabels = {
          app = "kafka"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "kafka"
          }
        }
        spec = {
          containers = [
            {
              name  = "kafka"
              image = "mucagriaktas/kafka:4.0.1"
              ports = [
                {
                  containerPort = 9092
                  name         = "broker"
                },
                {
                  containerPort = 9093
                  name         = "controller"
                },
              ]
              env = [
                {
                  name = "pod_name"
                  valueFrom = {
                    fieldRef = {
                      fieldPath = "metadata.name"
                    }
                  }
                },
                {
                  name = "replicas"
                  value = var.replicas
                }
              ]
              volumeMounts = [
                {
                  name      = "data"
                  mountPath = "/opt/kafka_data"
                }
              ]
            }
          ]
        }
      }
      volumeClaimTemplates = [
        {
          metadata = { name = "data" }
          spec = {
            accessModes = ["ReadWriteOnce"]
            storageClassName = "local-path"
            resources = { requests = { storage = var.storage_size } }
          }
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.kafka_headless_service]
}

##########################################################################################
###################################### EXTERNAL PORTS ####################################
##########################################################################################
locals {
  brokers      = range(var.replicas)
  broker_ports = { for b in local.brokers : b => 19092 + b * 10000 }
}

resource "kubernetes_manifest" "kafka_loadbalancer" {
  for_each = { for b in local.brokers : tostring(b) => b }
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "kafka-${each.value}-external"
      namespace = var.namespace
    }
    spec = {
      selector = {
        "statefulset.kubernetes.io/pod-name" = "kafka-${each.value}"
      }
      ports = [
        {
          name       = "external"
          port       = local.broker_ports[each.value]
          targetPort = local.broker_ports[each.value]
        }
      ]
      type = "LoadBalancer"
    }
  }
}
