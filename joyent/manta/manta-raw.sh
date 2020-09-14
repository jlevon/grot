#!/bin/bash

args=$(manta-auth-header)

echo curl $args ${MANTA_URL}$@
curl $args ${MANTA_URL}$@
