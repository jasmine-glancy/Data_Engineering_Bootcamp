# DataExpert.io Flink Homework

Welcome to the Streaming Pipelines chapter of the [DataExpert.io Bootcamp](https://www.dataexpert.io/)

## Prerequisites

In order to run these scripts, please note you'll need to install the following software:

1. Docker

    a. Install guide found [in the Docker documentation](https://docs.docker.com/engine/install/)

2. Postgres

    a. A nice install guide can be found in the [Data Engineer Handbook](https://github.com/DataExpert-io/data-engineer-handbook/tree/main/intermediate-bootcamp/materials/1-dimensional-data-modeling)

3. Python 3.11 or higher (found [on Python.org](https://www.python.org/downloads/))

## Setting Up the .Env

Utilizing environmental variables helps keep information safe. We can do this with the following steps:

1. Create a file called `.env`
2. Using one line per secret variable, please add variables for IP address, Kafka web traffic secret, Kafka web traffic key, Kafka URL, Kafka topic, Kafka group, Postgres username, and Postgres password

   a. Variables should be added via the following format: `VARIABLE_NAME="secret"`

3. Using `import os` in any file you reference an environmental variable is crucial. This has already been done in the two Python files.
4. Filling in the IP address
5. Filling in the Kafka web traffic secret and key
6. Filling in the Kafka URL, topic, and group
7. Filling in the Postgres user information and password

TODO: Instruct users how to set up their .env file securely (without giving Zach secrets)

## Running the Scripts

TODO: Provide a step-by-step guide on how to run the scripts

## Verifying Results

## Analysis and Insights

TODO: interpret and report results