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
