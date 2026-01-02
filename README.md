# Shared Hosting Engine

A collection of Bash scripts designed to automate the provisioning and management of shared hosting environments on Linux servers. It streamlines the creation of Nginx virtual hosts, PHP-FPM pools, MySQL databases, and more, with a focus on WordPress support.

## Project Overview

This toolset automates the manual tasks involved in setting up a web server stack. It handles:
*   **User Management**: Creating system users and groups for isolation.
*   **Web Server Config**: Generating Nginx configurations for HTTP and HTTPS.
*   **PHP Processing**: Setting up dedicated PHP-FPM pools for each site.
*   **Database**: Provisioning MySQL databases and users.
*   **Security**: Configuring Let's Encrypt SSL certificates, Basic Auth for dev sites, and OpenDKIM for email authentication.
*   **WordPress**: Automating WordPress installation via WP-CLI.

## Tech Stack

The project relies on the following technologies:
*   **Scripting**: Bash
*   **Web Server**: Nginx
*   **PHP Processor**: PHP-FPM (Configurable version, e.g., 7.4)
*   **Database**: MySQL
*   **SSL/TLS**: Let's Encrypt (via Certbot)
*   **Mail Security**: OpenDKIM
*   **Utilities**: WP-CLI, OpenSSL, Apache2 Utils (`htpasswd`)

## Project Structure

*   `create_site.sh`: Provisions a standard HTTP site (Nginx + PHP-FPM).
*   `create_dev_site.sh`: Provisions a development site with HTTPS (Let's Encrypt) and Basic Authentication.
*   `create_wp_dev_site.sh`: Provisions a WordPress development site with HTTPS, Basic Auth, and a MySQL database.
*   `create_db.sh`: Helper script to create a MySQL database and user.
*   `create_dkim_records.sh`: Generates DKIM keys and configures OpenDKIM for a domain.
*   `create_sftp_user.sh`: Creates an SFTP-only user mapped to an existing domain's owner.
*   `config.sh.sample`: Configuration template (must be copied to `config.sh`).
*   `templates/`: Nginx server blocks and PHP-FPM pool configuration templates.
*   `configs/`: Common Nginx configuration snippets (includes, modules, etc.).

## Installation & Setup (Verified)

**Important**: The scripts currently contain a hardcoded path assumption: `/root/tools/shared_engine/`. You must clone the repository to this specific location or update the scripts manually.

1.  **Clone the Repository**
    ```bash
    mkdir -p /root/tools
    cd /root/tools
    git clone <repository_url> shared_engine
    cd shared_engine
    ```

2.  **Install Dependencies**
    Ensure the following packages are installed on your system (Debian/Ubuntu assumed):
    ```bash
    apt-get update
    apt-get install nginx php-fpm mysql-server opendkim opendkim-tools certbot python3-certbot-nginx apache2-utils
    ```
    *Note: You may need specific PHP versions (e.g., `php7.4-fpm`) depending on your configuration.*

3.  **Install WP-CLI**
    The scripts assume `wp` is in your global PATH.
    ```bash
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    ```

4.  **Configure Nginx Includes**
    The templates rely on common configurations located in `common/`. You should copy the provided configs to your Nginx directory:
    ```bash
    mkdir -p /etc/nginx/common
    cp -r configs/nginx-common/* /etc/nginx/common/
    # Ensure /var/www/letsencrypt exists for Certbot webroot mode
    mkdir -p /var/www/letsencrypt
    ```

5.  **Configuration**
    Copy the sample config and edit it to match your environment:
    ```bash
    cp config.sh.sample config.sh
    nano config.sh
    ```
    *   **`PHPVERSION`**: The PHP version to use (e.g., `7.4`). This must match the installed PHP-FPM service (e.g., `service php7.4-fpm reload`).
    *   **`DKIM_SELECTOR`**: The selector string for OpenDKIM keys (defaults to hostname).

## Features & Usage

Run the scripts from the `/root/tools/shared_engine/` directory as `root`.

### Create a Standard Site
Creates a user, PHP-FPM pool, and Nginx HTTP config.
```bash
./create_site.sh
```
*   Prompts: Username, Domain.

### Create a Development Site (HTTPS + Auth)
Creates a site protected by Basic Auth and secured with Let's Encrypt.
```bash
./create_dev_site.sh
```
*   Prompts: Username, Domain.
*   **Note**: Generates a random password for Basic Auth and displays it at the end.

### Create a WordPress Development Site
Full stack setup: Nginx (HTTPS + Auth), PHP-FPM, MySQL, and WordPress core download/config.
```bash
./create_wp_dev_site.sh
```
*   Prompts: Username, Domain.
*   **Note**: Displays Database credentials and Basic Auth credentials upon completion.

### Create a Database Only
Creates a MySQL database and user with random credentials.
```bash
./create_db.sh
```
*   Prompts: Database prefix.

### Setup DKIM
Generates DKIM keys for a domain and updates OpenDKIM tables.
```bash
./create_dkim_records.sh
```
*   Prompts: Domain.
*   **Output**: Displays the DNS TXT record you need to add to your DNS provider.

### Create SFTP User
Adds an additional SFTP-only user to an existing site.
```bash
./create_sftp_user.sh
```
*   Interactively selects from existing domains in `/var/www/` (excluding `html` and `letsencrypt`).
*   Prompts: Username (appended to owner name).

## Environment Variables

The following variables are used in `config.sh`:

*   **`PHPVERSION`**: Controls which PHP-FPM socket and service to reload (e.g., `7.4` -> `php7.4-fpm`).
*   **`DKIM_SELECTOR`**: Used for generating DKIM keys.
