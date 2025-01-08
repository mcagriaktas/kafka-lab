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
###################################### KAFKA-STORAGE #####################################
##########################################################################################
resource "kubernetes_manifest" "kafka_storage" {
  manifest = {
    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"
    metadata = {
      name = "kafka-storage"
    }
    provisioner = "docker.io/hostpath"
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
######################################## BROKER 0 ########################################
##########################################################################################
resource "kubernetes_manifest" "kafka_statefulset_1" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "StatefulSet"
    metadata = {
      name      = "kafka-0"
      namespace = var.namespace
    }
    spec = {
      serviceName = "kafka-headless"
      replicas    = 1
      selector = {
        matchLabels = {
          app = "kafka"
          broker = "0"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "kafka"
            broker = "0"
          }
        }
        spec = {
          containers = [
            {
              name  = "kafka"
              image = "mucagriaktas/kafka:3.8.0"
              ports = [
                {
                  containerPort = 9092
                  name         = "broker"
                },
                {
                  containerPort = 9093
                  name         = "controller"
                },
                {
                  containerPort = var.broker_ports["broker0"]
                  name         = "external"
                }
              ]
              env = [
                {
                  name  = "node_id"
                  value = "0"
                },
                {
                  name  = "hostname"
                  value = "kafka-0-0.kafka-headless.kafka.svc.cluster.local"
                },
                {
                  name  = "EXTERNAL_PORT"
                  value = var.broker_ports["broker0"]
                },
                {
                  name  = "KAFKA_CLUSTER_MEMBERS"
                  value = "0@kafka-0-0.kafka-headless.kafka.svc.cluster.local:9093,1@kafka-1-0.kafka-headless.kafka.svc.cluster.local:9093,2@kafka-2-0.kafka-headless.kafka.svc.cluster.local:9093,3@kafka-3-0.kafka-headless.kafka.svc.cluster.local:9093"
                }
              ]
              volumeMounts = [
                {
                  name      = "data"
                  mountPath = "/data/kafka"
                }
              ]
            }
          ]
        }
      }
      volumeClaimTemplates = [
        {
          metadata = {
            name = "data"
          }
          spec = {
            accessModes = ["ReadWriteOnce"]
            storageClassName = "kafka-storage"
            resources = {
              requests = {
                storage = var.storage_size
              }
            }
          }
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.kafka_headless_service]
}

##########################################################################################
######################################## BROKER 1 ########################################
##########################################################################################
resource "kubernetes_manifest" "kafka_statefulset_2" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "StatefulSet"
    metadata = {
      name      = "kafka-1"
      namespace = var.namespace
    }
    spec = {
      serviceName = "kafka-headless"
      replicas    = 1
      selector = {
        matchLabels = {
          app = "kafka"
          broker = "1"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "kafka"
            broker = "1"
          }
        }
        spec = {
          containers = [
            {
              name  = "kafka"
              image = "mucagriaktas/kafka:3.8.0"
              ports = [
                {
                  containerPort = 9092
                  name         = "broker"
                },
                {
                  containerPort = 9093
                  name         = "controller"
                },
                {
                  containerPort = var.broker_ports["broker1"]
                  name         = "external"
                }
              ]
              env = [
                {
                  name  = "node_id"
                  value = "1"
                },
                {
                  name  = "hostname"
                  value = "kafka-1-0.kafka-headless.kafka.svc.cluster.local"
                },
                {
                  name  = "EXTERNAL_PORT"
                  value = var.broker_ports["broker1"]
                },
                {
                  name  = "KAFKA_CLUSTER_MEMBERS"
                  value = "0@kafka-0-0.kafka-headless.kafka.svc.cluster.local:9093,1@kafka-1-0.kafka-headless.kafka.svc.cluster.local:9093,2@kafka-2-0.kafka-headless.kafka.svc.cluster.local:9093,3@kafka-3-0.kafka-headless.kafka.svc.cluster.local:9093"
                }
              ]
              volumeMounts = [
                {
                  name      = "data"
                  mountPath = "/data/kafka"
                }
              ]
            }
          ]
        }
      }
      volumeClaimTemplates = [
        {
          metadata = {
            name = "data"
          }
          spec = {
            accessModes = ["ReadWriteOnce"]
            storageClassName = "kafka-storage"
            resources = {
              requests = {
                storage = "1Gi"
              }
            }
          }
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.kafka_headless_service]
}

##########################################################################################
######################################## BROKER 3 ########################################
##########################################################################################
resource "kubernetes_manifest" "kafka_statefulset_3" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "StatefulSet"
    metadata = {
      name      = "kafka-2"
      namespace = var.namespace
    }
    spec = {
      serviceName = "kafka-headless"
      replicas    = 1
      selector = {
        matchLabels = {
          app = "kafka"
          broker = "2"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "kafka"
            broker = "2"
          }
        }
        spec = {
          containers = [
            {
              name  = "kafka"
              image = "mucagriaktas/kafka:3.8.0"
              ports = [
                {
                  containerPort = 9092
                  name         = "broker"
                },
                {
                  containerPort = 9093
                  name         = "controller"
                },
                {
                  containerPort = var.broker_ports["broker2"]
                  name         = "external"
                }
              ]
              env = [
                {
                  name  = "node_id"
                  value = "2"
                },
                {
                  name  = "hostname"
                  value = "kafka-2-0.kafka-headless.kafka.svc.cluster.local"
                },
                {
                  name  = "EXTERNAL_PORT"
                  value = var.broker_ports["broker2"]
                },
                {
                  name  = "KAFKA_CLUSTER_MEMBERS"
                  value = "0@kafka-0-0.kafka-headless.kafka.svc.cluster.local:9093,1@kafka-1-0.kafka-headless.kafka.svc.cluster.local:9093,2@kafka-2-0.kafka-headless.kafka.svc.cluster.local:9093,3@kafka-3-0.kafka-headless.kafka.svc.cluster.local:9093"
                }
              ]
              volumeMounts = [
                {
                  name      = "data"
                  mountPath = "/data/kafka"
                }
              ]
            }
          ]
        }
      }
      volumeClaimTemplates = [
        {
          metadata = {
            name = "data"
          }
          spec = {
            accessModes = ["ReadWriteOnce"]
            storageClassName = "kafka-storage"
            resources = {
              requests = {
                storage = "1Gi"
              }
            }
          }
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.kafka_headless_service]
}

##########################################################################################
#################################### EXTERNAL SERVICES ###################################
##########################################################################################
resource "kubernetes_manifest" "kafka_service_broker_0" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "kafka-0-external"
      namespace = var.namespace
    }
    spec = {
      selector = {
        app = "kafka"
        broker = "0"
      }
      ports = [
        {
          name = "external"
          port = var.broker_ports["broker0"]
          targetPort = var.broker_ports["broker0"]
        }
      ]
      type = "LoadBalancer"
    }
  }
}

resource "kubernetes_manifest" "kafka_service_broker_1" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "kafka-1-external"
      namespace = var.namespace
    }
    spec = {
      selector = {
        app = "kafka"
        broker = "1"
      }
      ports = [
        {
          name = "external"
          port = var.broker_ports["broker1"]
          targetPort = var.broker_ports["broker1"]
        }
      ]
      type = "LoadBalancer"
    }
  }
}

resource "kubernetes_manifest" "kafka_service_broker_2" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "kafka-2-external"
      namespace = var.namespace
    }
    spec = {
      selector = {
        app = "kafka"
        broker = "2"
      }
      ports = [
        {
          name = "external"
          port = var.broker_ports["broker2"]
          targetPort = var.broker_ports["broker2"]
        }
      ]
      type = "LoadBalancer"
    }
  }
}