#!/usr/bin/env bash
# Writable Go caches for agent-swarm / OpenShift pods (node user, /home/node/go RO).

setup_go_env() {
  export GOMODCACHE="${GOMODCACHE:-/tmp/gomodcache}"
  export GOCACHE="${GOCACHE:-/tmp/gocache}"
  export GOPATH="${GOPATH:-/tmp/gopath}"
  mkdir -p "$GOMODCACHE" "$GOCACHE" "$GOPATH/bin"
}

setup_go_env
