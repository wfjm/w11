#!/bin/bash
# $Id: deploy.sh 1227 2022-04-24 10:08:48Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>

# get environment
printenv | sort | grep "^GITHUB_" > environment.log

# get tbfilt summary
tbfilt -all -sum -comp > tbfilt.log

# setup list of files to deploy
echo "environment.log" > deploy.lst
echo "tbfilt.log" >> deploy.lst
find -regextype egrep -regex '.*/tb_.*_[bfsorept]sim(_.*)?\.log' |\
     sort >> deploy.lst

# create tarball
tar -czf deploy.tgz -T deploy.lst

# upload
curl -w "status: %{http_code} send: %{size_upload} speed: %{speed_upload}\n" \
  -F 'repo=w11' \
  -F "runnum=$GITHUB_RUN_NUMBER" \
  -F "jobid=$JOBID"  \
  -F 'upfile=@deploy.tgz' \
  https://www.retro11.de/cgi-bin/upload_adeploy.cgi > deploy.log
cat deploy.log
