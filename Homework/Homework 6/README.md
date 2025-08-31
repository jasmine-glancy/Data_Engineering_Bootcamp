# DataExpert.io Flink Homework

Welcome to the Streaming Pipelines chapter of the [DataExpert.io Bootcamp](https://www.dataexpert.io/)! This code takes data from Kafka, hits the API for IP2Location, and geocodes IP addresses so we can see where the traffic is coming from and analyze the data.

## Prerequisites

In order to run these scripts, please note you'll need to install the following software:

1. Docker

    a. Install guide found [in the Docker documentation](https://docs.docker.com/engine/install/)

2. Postgres

    a. Please install using guide found in the [Data Engineer Handbook](https://github.com/DataExpert-io/data-engineer-handbook/tree/main/intermediate-bootcamp/materials/1-dimensional-data-modeling)

3. Python 3.11 or higher (found [on Python.org](https://www.python.org/downloads/))
4. Make (recommended)

    On most Linux distributions and macOS, make is typically pre-installed by default. To check if make is installed on your system, you can run the `make --version` command in your terminal or command prompt. If it's installed, it will display the version information.

    Otherwise, you can try following the instructions below, or you can just copy+paste the commands from the Makefile into your terminal or command prompt and run manually.

    ```shell
    # On Ubuntu or Debian:
    sudo apt-get update
    sudo apt-get install build-essential

    # On CentOS or Fedora:
    sudo dnf install make

    # On macOS:
    xcode-select --install

    # On windows:
    choco install make # uses Chocolatey, https://chocolatey.org/install
    ```

### Setting up Kafka and Flink

1. Clone the [Data Engineering Handbook](https://github.com/DataExpert-io/data-engineer-handbook/tree/main) repository

    ```shell
    git clone https://github.com/DataExpert-io/data-engineer-handbook.git

    # Navigate to the repository on your computer
    cd bootcamp/materials/4-apache-flink-training
    ```

2. Go to the [Apache Flink Training](https://github.com/DataExpert-io/data-engineer-handbook/tree/main/intermediate-bootcamp/materials/4-apache-flink-training) folder
3. Set up your .env file according to the steps [below](#setting-up-the-env-file)
4. Navigate to the `4-apache-flink-training` chapter of the data-engineer-handbook within your terminal
5. Run `docker compose --env-file flink-env.env up --build --remove-orphans -d` within your terminal to build the base Docker image and start the Flink cluster
6. Go to localhost:8081 to visit your Flink Job Manager once your Docker image is running

   a. Please ensure your Postgres container is running from the week 1 set up  

7. Go into Postgres and run the code found in [init.sql](https://github.com/DataExpert-io/data-engineer-handbook/blob/main/intermediate-bootcamp/materials/4-apache-flink-training/sql/init.sql) file to allow Postgres to collect the data
8. Run `docker compose exec jobmanager ./bin/flink run -py /opt/src/job/start_job.py --pyFiles /opt/src -d` to create the Kafka stream with Flink
9. If you have everything set up correctly, returning to your running jobs page at localhost:8081 should show a job currently running
10. The final check to make sure everything is set up is to return to Postgres. Running `SELECT * FROM processed_events` should return data

## Setting Up the .Env File

Utilizing environmental variables helps keep information safe. We can do this with the following steps:

1. Create a file called `flink-env.env`
2. Using one line per secret variable, please add variables for IP address, Kafka web traffic secret, Kafka web traffic key, Kafka URL, Kafka topic, Kafka group, Postgres username, and Postgres password

   a. Variables should be added via the following format: `VARIABLE_NAME=secret`

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

1. Build the Docker image and deploy the services in the docker-compose.yml file, including the PostgreSQL database and Flink cluster. This will (should) also create the sink table, processed_events, where Flink will write the Kafka messages to.

    ```shell
    make up

    # if you dont have make, you can run:
    # docker compose --env-file flink-env.env up --build --remove-orphans  -d
    ```

    Wait until the Flink UI is running at http://localhost:8081/ before proceeding to the next step.

    ***Note:*** the first time you build the Docker image it can take anywhere from 5 to 30 minutes. Future builds should only take a few second, assuming you haven't deleted the image since.

    Docker will automatically start up the job manager and task manager services after the image is built. This will take a minute or so. Check the container logs in Docker desktop and when you see the line below, you know you're good to move onto the next step.

    ```plaintext
    taskmanager Successful registration at resource manager akka.tcp://flink@jobmanager:6123/user/rpc/resourcemanager_* under registration id <id_number>
    ```

    Make sure to run sql/init.sql on the postgres database from Week 1 and 2 to have the processed_events table appear

2. When the Flink cluster is up and running, you can run the PyFlink job!

    ```shell
    make job

    # if you dont have make, you can run:
    # docker-compose exec jobmanager ./bin/flink run -py /opt/src/job/start_job.py -d
    ```

    After about a minute, you should see a prompt that the job's been submitted (e.g., `Job has been submitted with JobID <job_id_number>`). Now go back to the [Flink UI](http://localhost:8081/#/job/running) to see the job running!

3. Trigger an event from the Kafka source by visiting https://bootcamp.techcreator.io/ and then query the `processed_events` table in your postgreSQL database to confirm the data/events were added.

    ```shell
    make psql
    # or see `Makefile` to execute the command manually in your terminal or command prompt

    # expected output:
    docker exec -it eczachly-flink-postgres psql -U postgres -d postgres
    psql (15.3 (Debian 15.3-1.pgdg110+1))
    Type "help" for help.

    postgres=# SELECT COUNT(*) FROM processed_events;
    count 
    -------
    739
    (1 row)
    ```

4. When you're done, you can stop and/or clean up the Docker resources by running the commands below.

    ```shell
    make stop # to stop running services in docker compose
    make down # to stop and remove docker compose services
    make clean # to remove the docker container and dangling images
    ```

    ❕ Note the /var/lib/postgresql/data directory inside the PostgreSQL container is mounted to the ./postgres-data directory on your local machine. This means the data will persist across container restarts or removals, so even if you stop/remove the container, you won't lose any data written within the container.

## Verifying Results

In order to verify the Flink output against the source of truth, please use the queries in the `cross-verify.sql` file.

1. The file first counts the number of events in a single session per IP address and host
2. The second query averages the number of session events for specific hosts.

## Analysis and Insights

At the time of writing this, there are two free bootcamps currently being offered by the DataExpert.io umbrella (with a third on the way!). With that in mind, it makes sense to me that `www.fullstackexpert.io` (#1), `learn.dataexpert.io` (#2), and `www.dataexpert.io` (#3) are at the top of the list. From what I know about the websites, these are where folks complete the lessons, so the active events are likely generated mostly from current students.

The Cyber Instructor is coming out with a bootcamp that begins in September 2025, so `codingbootcamp.thecyberinstructor.com` is currently at the middle of the list. It was really interesting to plug in my own IP address and see my own stats!