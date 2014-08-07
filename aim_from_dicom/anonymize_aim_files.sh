#!/bin/bash
# Remove some PHI from AIM files

# By Daniel Golden (dgolden1 at stanford dot edu) March 2013
# $Id$


# for redactionTerms in name, patientID, birthDate
sed -E -i "" 's/(name=")[A-Za-z ]+/\1REDACTED/' "$1"
sed -E -i "" 's/(patientID=")[A-Za-z0-9]+/\1/' "$1"
sed -E -i "" 's/(birthDate=")[0-9:T-]+/\1/' "$1"

