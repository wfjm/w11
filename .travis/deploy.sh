#!/bin/bash
# $Id: deploy.sh 1194 2019-07-20 07:43:21Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>

# get environment
printenv | sort | grep "^TRAVIS_" > environment.log

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
  -F 'trepo=w11' \
  -F "tbldnum=$TRAVIS_BUILD_NUMBER" \
  -F "tjobnum=$TRAVIS_JOB_NUMBER"  \
  -F 'upfile=@deploy.tgz' \
  https://www.retro11.de/cgi-bin/upload_tdeploy.cgi > deploy.log
cat deploy.log
