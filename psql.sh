#!/bin/bash
docker run -it --rm --network pgnetwork postgres psql -h postgres -U postgres
