#!/bin/sh

#bin/bsah - l  
#pod trunk register tonychanchen@gmail.com 'eagleychen' --description='macbook pro'
#pod trunk add-owner TIoTLinkKit tonychanchen@gmail.com

chmod 0600 ~/.netrc

pod trunk push --allow-warnings
