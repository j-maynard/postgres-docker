#!/bin/bash
if [[ -z $PSQL_PORT ]]; then
    PSQL_PORT=5432
fi
docker run -it --rm --network pgnetwork postgres psql -h postgres -p $PSQL_PORT -U postgres
