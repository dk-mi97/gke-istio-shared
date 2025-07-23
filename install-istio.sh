#! /usr/bin/env bash

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# shellcheck source=verify-functions.sh

# This script creates all of the Istio deployments and services necessary for
# Istio to function.

ISTIO_DIR="${1}"
ISTIO_YAML="${2}"
ISTIO_NAMESPACE="${3}"
SHARED_DIR="${4}"
ISTIO_VERSION="${5:-latest}"

# Download istio if directory doesn't exist
if [ ! -d "$ISTIO_DIR" ]; then
    echo "Downloading Istio version $ISTIO_VERSION"
    curl -L https://github.com/istio/istio/releases/download/$ISTIO_VERSION/istio-$ISTIO_VERSION-linux-amd64.tar.gz | tar xz -C /tmp
    mv /tmp/istio-$ISTIO_VERSION $ISTIO_DIR
fi

# Load environment configuration
ENV="${5:-dev}"
source "$SHARED_DIR/environment-config.sh" $ENV
source "${SHARED_DIR}/verify-functions.sh"

echo "Installing Istio for environment: $ENV"
echo "Using namespace: $ISTIO_NAMESPACE"

#  install istio on the cluster
kubectl apply -f "${ISTIO_DIR}/install/kubernetes/${ISTIO_YAML}"

# Verify the Istio services are installed
for SERVICE_LABEL in "grafana" "istio-citadel" "istio-egressgateway" \
  "istio-ingressgateway" "istio-pilot" "istio-policy" "istio-sidecar-injector" \
  "istio-statsd-prom-bridge" "istio-telemetry" "prometheus" "servicegraph" \
  "tracing" "zipkin"; do
  # Poll 3 times on a 5 second interval
  if ! service_is_installed "${SERVICE_LABEL}" 3 5 "${ISTIO_NAMESPACE}" ; then
    echo "Service ${SERVICE_LABEL} in Istio deployment is not created. Aborting..."
    exit 1
  fi
done

# Verify the Istio pods are up and running
for POD_LABEL in "istio=pilot" "istio=mixer"; do
  if ! pod_is_running "${POD_LABEL}" 30 10 "${ISTIO_NAMESPACE}" ; then
    echo "Pod ${POD_LABEL} in Istio deployment is not running. Aborting..."
    exit 1
  fi
done

