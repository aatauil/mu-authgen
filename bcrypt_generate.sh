#!/bin/bash

# Step 1: Create the folder and initialize the Node.js project
echo "Setting up the environment..."

mkdir bcrypt-generator
cd bcrypt-generator

# Initialize Node.js project without any prompts
npm init -y > /dev/null 2>&1

# Install bcryptjs silently
npm install bcryptjs > /dev/null 2>&1

# Step 2: Ask the user for the required inputs
read -p "Enter your password: " password
read -p "Enter the application salt: " application_salt
read -p "Enter the account name: " account_name
read -p "Enter the session role: " session_role

# Generate UUIDs for person and account
person_uuid=$(uuidgen)
account_uuid=$(uuidgen)

# Automatically generate a random account salt (32-character hex string)
account_salt=$(openssl rand -hex 16)

# Get the current date in the required format
current_date=$(date --utc +"%Y-%m-%dT%H:%M:%S+00:00")

# Step 3: Create the Node.js script to generate the bcrypt hash
echo "Creating Node.js script..."

cat <<EOF > bcrypt_hash.js
const bcrypt = require('bcryptjs');

// Get input from shell script arguments
const password = process.argv[2];
const applicationSalt = process.argv[3];
const accountSalt = process.argv[4];

// Combine the password and salts
const combinedPassword = password + applicationSalt + accountSalt;

// Generate the bcrypt hash with a cost factor of 12
bcrypt.hash(combinedPassword, 12, function(err, hashedPassword) {
  if (err) {
    console.error('Error generating bcrypt hash:', err);
    return;
  }
  // Output the hash to a text file
  const fs = require('fs');
  fs.writeFileSync('bcrypt_hash.txt', hashedPassword);
  console.log('Hashed password saved in bcrypt_hash.txt');
});
EOF

# Step 4: Run the Node.js script to generate the bcrypt hash
echo "Generating bcrypt hash..."

node bcrypt_hash.js "$password" "$application_salt" "$account_salt"

# Read the generated hash from file
bcrypt_hash=$(cat bcrypt_hash.txt)

# Step 5: Generate the SPARQL query
echo "Creating SPARQL query..."

cat <<EOF > sparql_query.txt
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX people: <http://mow.data.gift/people/>
PREFIX accounts: <http://mow.data.gift/accounts/>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX mu:      <http://mu.semte.ch/vocabularies/core/>
PREFIX ext:      <http://mu.semte.ch/vocabularies/ext/>
PREFIX account: <http://mu.semte.ch/vocabularies/account/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA {
   GRAPH <http://mu.semte.ch/application> {
     people:$person_uuid a foaf:Person ;
                   foaf:name "$account_name";
                   foaf:account accounts:$account_uuid;
                   mu:uuid "$person_uuid";
                   dcterms:created "$current_date"^^xsd:datetime;
                   dcterms:modified "$current_date"^^xsd:datetime.
     accounts:$account_uuid a foaf:OnlineAccount;
                            foaf:accountName "$account_name";
                            mu:uuid "$account_uuid";
                            account:password """$bcrypt_hash""";
                            account:salt "$account_salt";
                            account:status <http://mu.semte.ch/vocabularies/account/status/active>;
                            dcterms:created "$current_date"^^xsd:datetime;
                            ext:sessionRole "$session_role";
                            dcterms:modified "$current_date"^^xsd:datetime.
   }
}
EOF

echo "SPARQL query saved in sparql_query.txt"

# Step 6: Clean up
echo "Cleaning up..."

# Move the output files outside the folder
mv bcrypt_hash.txt ../bcrypt_hash.txt
mv sparql_query.txt ../sparql_query.txt

# Clean up the directory
cd ..
rm -rf bcrypt-generator

echo "Hash generation complete. Check bcrypt_hash.txt and sparql_query.txt for the results."
