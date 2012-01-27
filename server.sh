#!/bin/sh

supervisor -w api,package.json,app.js -e 'node|js|coffee' app.js

