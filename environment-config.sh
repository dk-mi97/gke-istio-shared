#!/bin/bash

# Environment-specific configurations
ENVIRONMENT="${1:-dev}"

case $ENVIRONMENT in
    "dev")
        ISTIO_NAMESPACE="istio-system-dev"
        GRAFANA_ENABLED="true"
        JAEGER_ENABLED="true"
        LOG_LEVEL="debug"
        ;;
    "staging")
        ISTIO_NAMESPACE="istio-system-staging"  
        GRAFANA_ENABLED="true"
        JAEGER_ENABLED="false"
        LOG_LEVEL="info"
        ;;
    "prod")
        ISTIO_NAMESPACE="istio-system"
        GRAFANA_ENABLED="false"
        JAEGER_ENABLED="false"
        LOG_LEVEL="warn"
        ;;
esac

export ISTIO_NAMESPACE GRAFANA_ENABLED JAEGER_ENABLED LOG_LEVEL
