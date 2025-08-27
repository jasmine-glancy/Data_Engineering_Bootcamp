# DataExpert.io Flink Homework

Welcome to the Streaming Pipelines chapter of the [DataExpert.io Bootcamp](https://www.dataexpert.io/)

## Prerequisites

In order to run these scripts, please note you'll need to install the following software:

1. Docker

    a. Install guide found [in the Docker documentation](https://docs.docker.com/engine/install/)

2. Postgres

    a. A nice install guide can be found in the [Data Engineer Handbook](https://github.com/DataExpert-io/data-engineer-handbook/tree/main/intermediate-bootcamp/materials/1-dimensional-data-modeling)

3. Python 3.11 or higher (found [on Python.org](https://www.python.org/downloads/))

### Setting up Kafka and Flink

1. Clone the [Data Engineering Handbook](https://github.com/DataExpert-io/data-engineer-handbook/tree/main) repository
2. Go to the [Apache Flink Training](https://github.com/DataExpert-io/data-engineer-handbook/tree/main/intermediate-bootcamp/materials/4-apache-flink-training) folder
3. Set up your .env file according to the steps [below](#setting-up-the-env)

## Setting Up the .Env

Utilizing environmental variables helps keep information safe. We can do this with the following steps:

1. Create a file called `flink-env.env`
2. Using one line per secret variable, please add variables for IP address, Kafka web traffic secret, Kafka web traffic key, Kafka URL, Kafka topic, Kafka group, Postgres username, and Postgres password

   a. Variables should be added via the following format: `VARIABLE_NAME="secret"`

3. Using `import os` in any file you reference an environmental variable is crucial. This has already been done in the two Python files.

    a. Within the code, these environmental variables are referenced with `os.environ.get("ENVIRONMENTAL_VARIABLE_HERE")`

4. Filling in the IP address

    a. Going to [IP2Location](https://www.ip2location.com) and registering for a free account allows you to find your IP address.

    b. Copy and paste the number under IP address and add it to your `IP_ADDRESS` variable in your .env file

5. Filling in the Kafka web traffic secret and key

    a. The Kafka web traffic secret and key can be found in the "Flink Lab Setup" lecture of Zach Wilson's [Data Engineering Bootcamp](https://www.dataexpert.io/)

6. Filling in the Kafka URL, topic, and group

    a. This can be found under the [example.env](https://github.com/DataExpert-io/data-engineer-handbook/blob/main/intermediate-bootcamp/materials/4-apache-flink-training/example.env) file in the Data Engineer Handbook

7. Filling in the Postgres user information and password

    a. The [Data Engineer Handbook on Github](https://github.com/DataExpert-io/data-engineer-handbook/tree/main/intermediate-bootcamp/materials/1-dimensional-data-modeling#step-3%EF%B8%8F%E2%83%A3-connect-to-postgresql) has a helpful installation guide to help you connect to Postgres

## Running the Scripts

TODO: Provide a step-by-step guide on how to run the scripts

## Verifying Results

## Analysis and Insights

TODO: interpret and report results