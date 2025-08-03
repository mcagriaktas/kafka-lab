#!/bin/bash

set -e

REQUIREMENTS=("mvn" "java" "wget" "git" "tar")

echo "Checking requirements..."
for pkg in "${REQUIREMENTS[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        echo "Error: '$pkg' is not installed or not in PATH."
        exit 1
    else
        echo "$pkg already installed."
    fi
done

echo "All requirements found!"

echo "Creating output folders"
mkdir -p ./output ./output/html_report/

JMETER_VERSION="5.6.3"
JMETER_TGZ="apache-jmeter-${JMETER_VERSION}.tgz"
JMETER_URL="https://dlcdn.apache.org//jmeter/binaries/${JMETER_TGZ}"

if [ ! -f "$JMETER_TGZ" ]; then
    echo "Downloading JMeter..."
    wget "$JMETER_URL"
else
    echo "JMeter archive already exists."
fi

if [ ! -d "apache-jmeter-${JMETER_VERSION}" ]; then
    echo "Extracting JMeter..."
    tar -xzf "$JMETER_TGZ"
else
    echo "JMeter directory already extracted."
fi

if [ ! -d "kloadgen" ]; then
    echo "Cloning KLoadGen repository..."
    git clone https://github.com/sngular/kloadgen.git
else
    echo "KLoadGen repo already exists."
fi

cd kloadgen

echo "Compiling KLoadGen package with Maven (plugin profile)..."
mvn clean install -P plugin

KLOADGEN_JAR="target/kloadgen-5.6.13.jar"
JMETER_EXT_DIR="../apache-jmeter-${JMETER_VERSION}/lib/ext/"

if [ -f "$KLOADGEN_JAR" ]; then
    echo "Copying kloadgen jar to JMeter ext directory..."
    cp "$KLOADGEN_JAR" "$JMETER_EXT_DIR"
else
    echo "Error: KLoadGen jar not found!"
    exit 1
fi

cd ..

echo "Delete source files."
rm -rf apache-jmeter-5.6.3.tgz kloadgen

echo "All steps completed successfully!"
