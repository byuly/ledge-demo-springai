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

# ----------------------------------------------------------------------------
# Apache Maven Wrapper startup batch script, version 3.3.2
# ----------------------------------------------------------------------------

set -e

# Find the project base dir, i.e. the closest directory that contains a ".mvn" folder.
find_maven_basedir() {
  if [ -z "$1" ]
  then
    echo "Path not specified to find_maven_basedir"
    return 1
  fi

  basedir="$1"
  wdir="$1"
  while [ "$wdir" != '/' ] ; do
    if [ -d "$wdir"/.mvn ] ; then
      basedir=$wdir
      break
    fi
    # workaround for JBEAP-8937 (ECMA-262, 10.2.3 The Environment Record writeValue Operation)
    wdir=$(cd "$wdir/.."; pwd)
  done
  printf '%s' "$(cd "$basedir"; pwd)"
}

# concatenates all lines of a file
concat_lines() {
  if [ -f "$1" ]; then
    # Remove \r in case we run on Windows within Git Bash
    # 1. Trim BOM if any (for MacOS/Darwin)
    # 2. Remove \r on Windows
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
  exit 1;
fi

MAVEN_PROJECTBASEDIR=${MAVEN_BASEDIR:-"$BASE_DIR"}
log "$MAVEN_PROJECTBASEDIR"

##########################################################################################
# Extension to allow automatically downloading the maven-wrapper.jar from Maven-central
# This allows using the maven wrapper in projects that prohibit checking in binary data.
##########################################################################################
wrapperJarPath="$MAVEN_PROJECTBASEDIR/.mvn/wrapper/maven-wrapper.jar"
if [ -r "$wrapperJarPath" ]; then
    log "Found $wrapperJarPath"
else
    log "Couldn't find $wrapperJarPath, downloading it ..."

    if [ -n "$MVNW_REPOURL" ]; then
      wrapperUrl="$MVNW_REPOURL/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar"
    else
      wrapperUrl="https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar"
    fi
    while IFS="=" read -r key value; do
      # Remove '\r' from value to handle Windows line endings
      value=$(echo "$value" | tr -d '\r')
      case "$key" in (wrapperUrl) wrapperUrl="$value"; break ;;
      esac
    done < "$MAVEN_PROJECTBASEDIR/.mvn/wrapper/maven-wrapper.properties"
    log "Downloading from: $wrapperUrl"

    if $cygwin; then
      wrapperJarPath=$(cygpath --path --windows "$wrapperJarPath")
    fi

    if command -v wget > /dev/null; then
        log "Found wget ... using wget"
        [ "$MVNW_VERBOSE" = true ] && VERBOSE_OPT="--verbose" || VERBOSE_OPT="-q"
        # shellcheck disable=SC2086
        wget $VERBOSE_OPT "$wrapperUrl" -O "$wrapperJarPath" || rm -f "$wrapperJarPath"
    elif command -v curl > /dev/null; then
        log "Found curl ... using curl"
        [ "$MVNW_VERBOSE" = true ] && VERBOSE_OPT="" || VERBOSE_OPT="--silent"
        # shellcheck disable=SC2086
        curl $VERBOSE_OPT -o "$wrapperJarPath" "$wrapperUrl" -f || rm -f "$wrapperJarPath"
    else
        log "Falling back to using Java to download"
        javaSource="$MAVEN_PROJECTBASEDIR/.mvn/wrapper/MavenWrapperDownloader.java"
        javaClass="$MAVEN_PROJECTBASEDIR/.mvn/wrapper/MavenWrapperDownloader"
        # For Cygwin, switch paths to Windows format before running javac
        if $cygwin; then
          javaSource=$(cygpath --path --windows "$javaSource")
          javaClass=$(cygpath --path --windows "$javaClass")
        fi
        if [ -e "$javaSource" ]; then
            if [ ! -e "$javaClass.class" ]; then
                log " - Compiling MavenWrapperDownloader.java ..."
                ("$JAVA_HOME/bin/javac" "$javaSource")
            fi
            if [ -e "$javaClass.class" ]; then
                log " - Running MavenWrapperDownloader.java ..."
                ("$JAVA_HOME/bin/java" -cp .mvn/wrapper MavenWrapperDownloader "$wrapperUrl" "$wrapperJarPath") || rm -f "$wrapperJarPath"
            fi
        fi
    fi
fi
##########################################################################################
# End of extension
##########################################################################################

# If specified, validate the SHA-256 sum of the Maven wrapper jar file
wrapperSha256Sum=""
while IFS="=" read -r key value; do
  # Remove '\r' from value to handle Windows line endings
  value=$(echo "$value" | tr -d '\r')
  case "$key" in (wrapperSha256Sum) wrapperSha256Sum=$value; break ;;
  esac
done < "$MAVEN_PROJECTBASEDIR/.mvn/wrapper/maven-wrapper.properties"
if [ -n "$wrapperSha256Sum" ]; then
  wrapperSha256Result=false
  if command -v sha256sum > /dev/null; then
    if echo "$wrapperSha256Sum  $wrapperJarPath" | sha256sum -c > /dev/null 2>&1; then
      wrapperSha256Result=true
    fi
  elif command -v shasum > /dev/null; then
    if echo "$wrapperSha256Sum  $wrapperJarPath" | shasum -a 256 -c > /dev/null 2>&1; then
      wrapperSha256Result=true
    fi
  else
    echo "Checksum validation was requested but neither 'sha256sum' nor 'shasum' are available."
    echo "Please install either command, or disable validation by removing 'wrapperSha256Sum' from your maven-wrapper.properties."
    exit 1
  fi
  if [ $wrapperSha256Result = false ]; then
    echo "Error: Failed to validate Maven wrapper SHA-256, your Maven wrapper installation is corrupt."
    echo "Investigate or delete $wrapperJarPath to attempt a clean download."
    echo "If you updated your Maven version, you need to update the specified wrapperSha256Sum property."
    exit 1
  fi
fi

MAVEN_OPTS="$(concat_lines "$MAVEN_PROJECTBASEDIR/.mvn/jvm.config") $MAVEN_OPTS"

# shellcheck disable=SC2086
find_file_argument_to_executor() {
    local args=( "$@" )
    local is_next_file=0
    for arg in "${args[@]}"; do
        if [ $is_next_file -eq 1 ]; then
            echo "$arg"
            break
        fi
        if [ "$arg" = "--file" ] || [ "$arg" = "-f" ]; then
            is_next_file=1
        fi
    done
}

# Provide a "standardized" way to retrieve the CLI args that will
# work with both the new and older argument styles. This is a hack.
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
