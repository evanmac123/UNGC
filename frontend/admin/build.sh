#!/bin/bash

ember build --environment=production
cp dist/assets/admin.js dist/assets/vendor.js ../../app/assets/javascripts/redesign/
cp dist/assets/admin.css dist/assets/vendor.css ../../app/assets/javascripts/redesign/
cp dist/assets/*gif dist/assets/*png ../../app/assets/images
