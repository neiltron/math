require 'oauth2/provider'
OAuth2::Provider.realm = 'Mathematics'

PERMISSIONS = {
  'read_records' => 'Read all items and records',
  'write_records' => 'Create new records'
}
ERROR_RESPONSE = JSON.unparse('error' => 'No soup for you!')