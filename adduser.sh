#!/bin/bash
set -e  # Exit on any error

# Usage check: Ensure exactly one argument is passed (username)
if [ $# -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# User information
USERNAME=$1
USER_DIR="/var/dav/$USERNAME"             # Update path to match container
HTPASSWD_FILE="/etc/nginx/snippets/$USERNAME-htpasswd"  # Update path for .htpasswd file
USER_SERVING_FOLDER="/var/dav/basic-auth"
USER_SERVING_DIR="$USER_SERVING_FOLDER/$USERNAME"  # Directory to serve for the user

# Check if the user directory already exists
if [ -d "$USER_DIR" ]; then
    echo "Error: User '$USERNAME' already exists."
    exit 1
fi

# Prompt for the password securely
echo -n "Enter password for user '$USERNAME': "
read -s PASSWORD
echo
echo -n "Confirm password for user '$USERNAME': "
read -s PASSWORD_CONFIRM
echo

# Check if passwords match
if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
    echo "Error: Passwords do not match. Please try again."
    exit 1
fi

# Create the user directory
echo "Creating directory for user '$USERNAME'..."
mkdir -p "$USER_DIR"

# Create a simple index.html file for testing in the user directory
echo "Creating index.html for testing in $USER_DIR..."
echo "<html><body><h1>Welcome to $USERNAME's WebDAV directory!</h1></body></html>" > "$USER_DIR/index.html"

# Create the user's serving folder (inside USER_SERVING_FOLDER)
echo "Creating directory for '$USERNAME' inside basic-auth..."
mkdir -p "$USER_SERVING_DIR"
echo "Created directory: $USER_SERVING_DIR"

# Create a personalized index.html file in the user's serving folder
echo "Creating personalized index.html in the serving directory..."
echo "<html><body><h1>Hello, $USERNAME!</h1></body></html>" > "$USER_SERVING_DIR/index.html"

# Check if the /etc/nginx/snippets/ directory is writable
if [ ! -w /etc/nginx/snippets/ ]; then
    echo "Error: /etc/nginx/snippets/ directory is not writable."
    echo "Attempting to fix permissions..."
    chmod 755 /etc/nginx/snippets/
    chown root:root /etc/nginx/snippets/
fi

# Generate .htpasswd for Basic Authentication
echo "Creating .htpasswd file for '$USERNAME'..."
htpasswd -bc "$HTPASSWD_FILE" "$USERNAME" "$PASSWORD"

# Set permissions for the user directory to allow Nginx to read/write
echo "Setting permissions for user directory '$USERNAME'..."
chown -R nginx:nginx "$USER_DIR"
chmod -R 755 "$USER_DIR"

# Set permissions for the .htpasswd file
echo "Setting permissions for .htpasswd file..."
chown nginx:nginx "$HTPASSWD_FILE"
chmod 644 "$HTPASSWD_FILE"

# Set permissions for the user serving directory
echo "Setting permissions for user serving directory '$USER_SERVING_DIR'..."
chown -R nginx:nginx "$USER_SERVING_DIR"
chmod -R 755 "$USER_SERVING_DIR"

# Inform the user that everything is set up
echo "User '$USERNAME' has been successfully added."
echo "Directory created at '$USER_DIR' with a test index.html file."
echo "Personalized index.html created in the serving directory at '$USER_SERVING_DIR'."
echo "Basic Authentication file created at '$HTPASSWD_FILE'."
