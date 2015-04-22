#!/bin/bash
#
#   Author :        ADW 04/15
#
#   Use :           Parses (a std format) apache access_log to generate a
#                   couple of reports highlighting any pages producting
#                   HTTP 404 error codes and the pages that referred them.
#                   a) (Indirect) 404s produced by referral from another page.
#                   b) (Direct)   404s produced without a referral page.
#
#  Notes :          Excludes any 404s triggered by monitoring.
#
#  Logging :        Logs a copy of the reports to LogDir.
#                   Filename only includes date, so only run daily.

# Enable default error handling
# TIP: To prevent (acceptable) errors halting the program
#      Suffix the cmd with || true
#      e.g. this wont work || true
set -o errexit -o pipefail -o nounset

# Be nice
renice 15 -p $$

## CONFIG
confFile=$0.config
. $confFile || (echo "Failed running $confFile" && exit 1)

#Log=/var/log/httpd/access_log
#LogDir=~/log/http404Report
#Email=""

# Perl script to parse the access log and do the aggregations.
Script=$(dirname $0)/http404Report.pl
## END CONFIG

## MAIN
[ -d $LogDir ] || (mkdir -p $LogDir && echo "Created LogDir=$LogDir")

dte=$(date +%F)
hostname=$(hostname)
log=$LogDir/$dte

# Strip out lines triggered by monitoring and direct links.
# This sends an attachment...
# This is currently too large to be emailled uncompressed.
grep ' 404 ' $Log | egrep -v '^127.0.0.1| \"-\" ' \
    | awk '{ print $7, $11 }' \
    | $Script -u \
    | tee "$log-indirect.log" \
    | mail -s "Indirect HTTP 404 Report for $hostname" $Email

grep ' 404 ' $Log | egrep -v '^127.0.0.1' | grep ' \"-\" ' \
    | awk '{ print $7, $11 }' \
    | $Script -u \
    | tee "$log-direct.log" \
    | mail -s "Direct HTTP 404 Report for $hostname" $Email

bzip2 $log-*.log > /dev/null 2>&1

exit 0

## END MAIN
# vim: autoindent:expandtab:tabstop=4
