#! /bin/bash

gem build yaml-twine-formatter.gemspec &&
mkdir -p bin &&
mv *.gem bin/