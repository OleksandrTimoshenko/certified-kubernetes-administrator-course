#!/bin/bash

vagrant destroy -f && POFT_FORWARDING_TO_HOST=true SINGLE_THREAD_MODE=false vagrant up