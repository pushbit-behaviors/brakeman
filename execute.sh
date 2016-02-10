#!/bin/bash

brakeman -f json | ruby ../execute.rb