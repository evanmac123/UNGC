#!/bin/bash

ember build --environment=production
cp dist/assets/admin.js dist/assets/vendor.js ../../app/assets/javascripts/redesign-admin/
cp dist/assets/admin.css dist/assets/vendor.css ../../app/assets/stylesheets/redesign-admin/
cp dist/assets/*gif dist/assets/*png ../../app/assets/images
