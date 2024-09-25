# mu-authgen

`mu-authgen` is a simple shell script to generate bcrypt-hashed credentials and SPARQL queries for user accounts, designed for use in `mu.semte.ch` applications.

## Overview

This script helps you easily create user credentials without the need to set up the [mu-semtech/registration-service](https://github.com/mu-semtech/registration-service). You can use this tool to generate accounts and credentials that are compatible with the [mu-semtech/login-service](https://github.com/mu-semtech/login-service).

## Features

- Automatically generates bcrypt hashes for passwords.
- Creates SPARQL insert queries to store user credentials.
- Simple setup with no additional dependencies beyond Node.js and OpenSSL.

## Requirements

- Bash shell
- Node.js
- OpenSSL (for generating salts)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/aatauil/mu-authgen.git
   ```

2. Make the script executable:
   ```bash
   chmod +x bcrypt_generate.sh
   ```

## Usage

1. Run the script:
   ```bash
   ./bcrypt_generate.sh
   ```

2. The script will prompt you for the following information:
   - Password
   - Global salt (shared across accounts)
   - Account name
   - Session role

3. The script will automatically:
   - Generate a unique `account_salt`.
   - Create a bcrypt hash for the provided password.
   - Generate a SPARQL insert query for the account.

4. The results will be saved in two files:
   - `bcrypt_hash.txt`: Contains the bcrypt hash.
   - `sparql_query.txt`: Contains the SPARQL query to insert the account data into your application’s triple store.

## Clean-Up

After execution, the script cleans up temporary files, leaving only the final `bcrypt_hash.txt` and `sparql_query.txt` files in the directory.

## License

This project is licensed under the MIT License.
