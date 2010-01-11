# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_othello_session',
  :secret      => '1f9be7d5b5bf3ca3e6bb5f157032d069cf434e75e3ba6d7cd6f645aebce8e61dd6e3d6e3c614f40eda66a533ac0be838e29a9c305437feb40874808ff6df64ea'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
