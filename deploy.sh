#!/usr/bin/env bash

# Get the plugin slug from this git repository.
PLUGIN_SLUG="${PWD##*/}"

# Get the current release version
TAG=$(sed -e "s/refs\/tags\///g" <<< $GITHUB_REF)
VERSION="${TAG//v}"

# Replace the version in these 2 files.
# sed -i -e "s/__STABLE_TAG__/$TAG/g" ./src/readme.txt
# sed -i -e "s/__STABLE_TAG__/$TAG/g" "./src/$PLUGIN_SLUG.php"

# Get the SVN data from wp.org in a folder named `svn`
# svn co --depth immediates "https://plugins.svn.wordpress.org/$PLUGIN_SLUG" ./svn
SVN_URL="https://plugins.svn.wordpress.org/wp-menu-cart/"
SVN_DIR="/github/svn-wp"
svn checkout --depth immediates "$SVN_URL" "$SVN_DIR"

# Switch to SVN directory
cd "$SVN_DIR"

svn update --set-depth infinity trunk
svn update --set-depth infinity tags/$VERSION

# Copy files from release to `svn/trunk`
rsync -avr --exclude-from="$GITHUB_WORKSPACE/.distignore" "$GITHUB_WORKSPACE/" trunk/

# Prepare the files for commit in SVN
svn add --force trunk

# Create the version tag in svn
svn cp "trunk" "tags/$VERSION"

# Prepare the tag for commit
svn add --force tags

# Commit files to wordpress.org.
svn ci  --message "Release $TAG" \
        --username $SVN_USERNAME \
        --password $SVN_PASSWORD \
        --non-interactive

#### REPEAT FOR woocommerce-menu-bar-cart ####

# Overwrite plugin name
sed -i -e "s/=== WP Menu Cart ===/=== WooCommerce Menu Cart ===/g" "$GITHUB_WORKSPACE/readme.txt"
sed -i -e "s/Plugin Name: WP Menu Cart/Plugin Name: WooCommerce Menu Cart/g" "$GITHUB_WORKSPACE/wp-menu-cart.txt"

# Get the SVN data from wp.org in a folder named `svn`
SVN_URL="https://plugins.svn.wordpress.org/woocommerce-menu-bar-cart/"
SVN_DIR="/github/svn-wc"
svn checkout --depth immediates "$SVN_URL" "$SVN_DIR"

# Switch to SVN directory
cd "$SVN_DIR"

svn update --set-depth infinity trunk
svn update --set-depth infinity tags/$VERSION

# Copy files from release to `svn/trunk`
rsync -avr --exclude-from="$GITHUB_WORKSPACE/.distignore" "$GITHUB_WORKSPACE/" trunk/

# Prepare the files for commit in SVN
svn add --force trunk

# Create the version tag in svn
svn cp "trunk" "tags/$VERSION"

# Prepare the tag for commit
svn add --force tags

# Commit files to wordpress.org.
svn ci  --message "Release $TAG" \
        --username $SVN_USERNAME \
        --password $SVN_PASSWORD \
        --non-interactive
