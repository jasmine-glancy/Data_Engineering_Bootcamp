# Spark Fundamentals Training

## Table of Contents

- [Getting Started: Unit Testing Pyspark](#getting-started-unit-testing-pyspark)
- [Install Spark and Python](#install-spark-and-python)
  - [Installing Spark and Python on Windows](#installing-spark-and-python-on-windows)
  - [Installing Spark and Python on Mac](#installing-spark-and-python-on-mac)
- [Common Errors and Fixes](#common-errors--fixes)

## Getting Started: Unit Testing PySpark

1. Please clone the [Data Engineer Handbook Repository on GitHub](https://github.com/DataExpert-io/data-engineer-handbook/tree/main)

2. Run `pip install -r requirements.txt` to install the required dependencies to run the code in these folders.

## Install Spark and Python

Thank you to Ruhal and team for the following guides. Running `python -m pytest`

### Installing Spark and Python on Windows

#### Install OpenJDK 17

1. Download OpenJDK 17 [here](https://jdk.java.net/java-se-ri/17-MR1)
2. Install OpenJDK 17
3. Set up environment variables:

    a. Open the System Properties window.

    b. Go to the "Advanced" tab and click on "Environment Variables".

    c. Under "System variables," click "New" and add `JAVA_HOME` pointing to your OpenJDK installation directory.

    d. Add `%JAVA_HOME%\bin` to the `Path` variable.

#### Install Python 3.11.8

1. Download Python 3.11.8 from the official Python website.
2. Install Python.
3. Add Python to the `Path` variable:

    a. Open the System Properties window.

    b. Go to the "Advanced" tab and click on "Environment Variables".

    c. Under "System variables," click "Edit" for the `Path` variable and add `%PYTHON_HOME%\Scripts` and `%PYTHON_HOME%\`.

#### Install Apache Spark

1. Download the latest version of Spark from the Apache Spark page.
2. Extract the downloaded Spark archive to a directory, e.g., `C:\apps\spark-latest`.

#### Set Up Environment Variables for Spark

1. Open the System Properties window.
2. Go to the "Advanced" tab and click on "Environment Variables".
3. Under "System variables," click "New" and add `SPARK_HOME` pointing to your Spark installation directory.
Add `%SPARK_HOME%\bin` to the `Path` variable.

#### Install PySpark

Open Command Prompt and run the following command to install PySpark: `pip install pyspark`

#### Set `PYSPARK_PYTHON` and `PYSPARK_DRIVER_PYTHON` Environment Variables

1. Open the System Properties window.
2. Go to the "Advanced" tab and click on "Environment Variables".
3. Under "System variables and User variables" click "New" and add `PYSPARK_PYTHON` pointing to your Python executable, e.g., `C:\Python311\python.exe`.
4. Add `PYSPARK_DRIVER_PYTHON` pointing to your Python executable, e.g., `C:\Python311\python.exe`.
5. Add `%PYSPARK_PYTHON%` and `%PYSPARK_DRIVER_PYTHON%` to the `Path` variable.


#### Verify the Installation

1. Open Command Prompt and type pyspark to start the PySpark shell.
2. Verify that the PySpark shell starts without errors.

Note: rename folders or computer names to use only ASCII characters.

Steps credit to the [DataExpert.io Community Discord Channel](https://discord.com/channels/1106357930443407391/1388500306207178824).

### Installing Spark and Python on Mac

Pre-requisites

#### Install Brew

1. Go to [Brew Website](https://brew.sh/)
2. Copy the url from Home page on mac os terminal to install Home brew
3. Run `brew upgrade && brew update` to update home brew

#### Java Installation

1. Check Java Version with `java --version`
2. Run `brew install openjdk@17` to install openjdk17 if not installed
3. For the system Java wrappers to find this JDK, symlink it with `sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk`
4. Above can be checked using `brew info java`
5. Update shell configuration (~/.zshrc) with `nano ~/.zshrc export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"`
6. Reload shell configuration with `source ~/.zshrc`

#### Python Install

`brew install python@3.11`

#### Verify Installation

`python3 --version
pip3 --version`

#### Apache Spark Installation

`brew install apache-spark`

#### To Start Spark Shell

Execute `spark-shell`

Steps credit to the [DataExpert.io Community Discord Channel](https://discord.com/channels/1106357930443407391/1388501607641124874).

## Spark Fundamentals and Advanced Spark Setup

1. To launch the Spark and Iceberg Docker containers, run `docker compose up` on Windows or run `make up` on Mac.
2. You should be able to access a Jupyter notebook at `localhost:8888`

## Common Errors & Fixes

To fix Spark OutOfMemoryError, you need follow the below steps.

1. Adjust Docker resource allocation:  

   a. On the Docker desktop, go to  Settings >  Resources, increase memory limit slider to max (it might 8gb, 16gb depending on your machine).

   b. Adjust virtual disk limit to an higher number like 128G.

2. Update spark configs in the Iceberg container:

    a. On the Docker desktop, go to Containers > 3-spark-fundamentals > spark-iceberg > Files.

    b. Scroll down to opt>config, right click on spark-defaults-conf to edit it, scroll to the bottom, add the following 4 lines:

    ```plaintext
    spark.serializer                       org.apache.spark.serializer.KryoSerializer
    spark.driver.memory                    8g
    spark.memory.offHeap.enabled           true
    spark.memory.offHeap.size              8g
    ```

3. After doing the above steps, restart 3-spark-fundamentals container.
4. You also need reduce the bucket size to 4 or 8 instead of 16 depending on your machine RAM.