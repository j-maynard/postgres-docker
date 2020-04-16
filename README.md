# postgres-docker

This is a set of three scripts to run docker, pgadmin 4
and psql in Docker.  Saves having to install docker locally
and comes with the advantages of quick upgrades when new 
versions come out.

# Getting started

This is easy... 

```bash
./start.sh
```

This starts PostgreSQl on port 5432 its default port.

# PGAdmin 4

PGAdmin 4 is automatically run along side PostgreSQL.
To access PGAdmin 4 open a web browser and go to:

[http://localhost:5050](http://localhost:5050)

PGAdmin is bound to 5050.  The default username and password
for PGAdmin is:

Username: test@test.test
Password: 8lScP10eY1L3oeXbBM1E

When you first connect to PGAdmin 4 you'll need to set up a connection to the server.  To do this
where it asks you for a host the hostname is postgres and the port will be 5432 irrespective of what
you put in the commandline options or environemnt variables.  The user will be `postgres` and the password
will be the default password `docker` or what you specified in the commandline options or environemnet
variables.

# Shuting down

Again really simple...

```bash
./stop.sh
```

# PSQL Shell

If you need to access the psql shell from the command
line again this is very easy...

```bash
./psql.sh
```

When it asks you for a password, the default password
is `docker`

# Overriding stuff

There are two ways to override stuff in the scripts.  The first is you can use the commandline options and in the world of repeatability you can also set the options as environment variables.

## Environment Variables

For the start script you can override the following with environment variables:
* `PSQL_PASSWORD` - The default PostgreSQL password
* `PSQL_PORT` - The exposed PostgreSQL port (this is the port you give to locally running programs)
* `PGADMIN_PORT` - The port to access PGAdmin on
* `PGADMIN_USER` - The inital user to access PGAdmin
* `PGADMIN_PASSWORD` - The inital password to access PGAdmin with

For the stop script you can override the following:
* `KEEP_VOLS` - Removes the volumes and deletes all data after shutdown.  The only valid option is `false`
* `KEEP_NET` - Removes the pgnetwork which the start script creates.  The only valid option is `false`

## Commandline

As an alternatively to environemnt variables you can use the command the line.  Each script has a full list of usage instructions which can be accessed by running the script and appending `-h` or `--help`

The start script will output the following:
```
> ./start.sh --help
Usage:
  --psql-password     Sets the PostgreSQL password
                      (The default is 'docker')

  --psql-port         Sets the PostgreSQL port
                      (The default is '5432')

  --pgadmin-port      Sets the port for PGAdmin 4
                      (The default is '5050')

  --pgadmin-user      Sets the default login user for PGAdmin 4
                      (The default is 'test@test.test')

  --pgadmin-password  Sets the password for the default login for PGAdmin 4
                      (The default is '8lScP10eY1L3oeXbBM1E')

```

The stop script will out the following:
```
> ./stop.sh --help
Usage:
  -v    --remove-vols   Removes the docker volumes and their data
                        The default is to preserve the data
  -n    --remove-net    Removes the pgnetwork created by the start script
                        The default is to keep the network
  -h    --help          Shows this message

```