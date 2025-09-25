#!/bin/bash

if [ "$1" = "pull" ]; then
    # Pull latest changes from git
    git pull

    # Pull theme from Shopify
    shopify theme pull -s espritdevelop.myshopify.com -t 138370121793
else
    echo "Usage: $0 pull"
fi