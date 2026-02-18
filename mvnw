#!/bin/sh
# ----------------------------------------------------------------------------
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# ----------------------------------------------------------------------------

# Apache Maven Wrapper startup script, version 3.3.2

set -e

# OS specific support (must be 'true' or 'false').
cygwin=false
darwin=false
mingw=false
case "$(uname)" in
  CYGWIN*) cygwin=true ;;
  MINGW*)  mingw=true  ;;
  Darwin*) darwin=true ;;
esac

find_maven_basedir() {
  if [ -z "$1" ]; then
    echo "Path not specified to find_maven_basedir"
    return 1
  fi
  basedir="$1"
  wdir="$1"
  while [ "$wdir" != '/' ]; do
    if [ -d "$wdir"/.mvn ]; then
      basedir=$wdir
      break
    fi
    wdir=$(cd "$wdir/.."; pwd)
  done
  printf '%s' "$(cd "$basedir"; pwd)"
}

concat_lines() {
  if [ -f "$1" ]; then
    sed 's/\r$//' "$1" | tr -d '\r'
  fi
}

log() {
  if [ "$MVNW_VERBOSE" = true ]; then
    printf '%s\n' "$1"
  fi
}

BASE_DIR=$(find_maven_basedir "$(dirname "$0")")
if [ -z "$BASE_DIR" ]; then
  exit 1
fi

MAVEN_PROJECTBASEDIR=${MAVEN_BASEDIR:-"$BASE_DIR"}
log "$MAVEN_PROJECTBASEDIR"

# Download maven-wrapper.jar if missing
wrapperJarPath="$MAVEN_PROJECTBASEDIR/.mvn/wrapper/maven-wrapper.jar"
if [ -r "$wrapperJarPath" ]; then
    log "Found $wrapperJarPath"
else
    log "Downloading maven-wrapper.jar ..."
    wrapperUrl="https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar"
    while IFS="=" read -r key value; do
      value=$(echo "$value" | tr -d '\r')
      case "$key" in
        wrapperUrl) wrapperUrl="$value"; break ;;
      esac
    done < "$MAVEN_PROJECTBASEDIR/.mvn/wrapper/maven-wrapper.properties"
    log "Downloading from: $wrapperUrl"

    if command -v wget > /dev/null; then
        [ "$MVNW_VERBOSE" = true ] && VERBOSE_OPT="--verbose" || VERBOSE_OPT="-q"
        # shellcheck disable=SC2086
        wget $VERBOSE_OPT "$wrapperUrl" -O "$wrapperJarPath" || rm -f "$wrapperJarPath"
    elif command -v curl > /dev/null; then
        [ "$MVNW_VERBOSE" = true ] && VERBOSE_OPT="" || VERBOSE_OPT="--silent"
        # shellcheck disable=SC2086
        curl $VERBOSE_OPT -o "$wrapperJarPath" "$wrapperUrl" -f || rm -f "$wrapperJarPath"
    fi
fi

# Locate Java
if [ -n "$JAVA_HOME" ]; then
  if $cygwin; then
    JAVA_HOME=$(cygpath --unix "$JAVA_HOME")
  fi
  JAVACMD="$JAVA_HOME/bin/java"
  if [ ! -x "$JAVACMD" ]; then
    echo "JAVA_HOME ($JAVA_HOME) does not contain a valid java binary." >&2
    exit 1
  fi
else
  JAVACMD="$(command -v java 2>/dev/null)" || true
  if [ -z "$JAVACMD" ]; then
    echo "Java is not installed or not on PATH." >&2
    exit 1
  fi
fi

MAVEN_OPTS="$(concat_lines "$MAVEN_PROJECTBASEDIR/.mvn/jvm.config") $MAVEN_OPTS"
MAVEN_CMD_LINE_ARGS="$MAVEN_CONFIG $*"
export MAVEN_CMD_LINE_ARGS

WRAPPER_LAUNCHER=org.apache.maven.wrapper.MavenWrapperMain

# shellcheck disable=SC2086
exec "$JAVACMD" \
  $MAVEN_OPTS \
  $MAVEN_DEBUG_OPTS \
  -classpath "$wrapperJarPath" \
  "-Dmaven.multiModuleProjectDirectory=${MAVEN_PROJECTBASEDIR}" \
  ${WRAPPER_LAUNCHER} $MAVEN_CONFIG "$@"
