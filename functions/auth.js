const { auth } = require('google-auth-library');

/**
 * Gets an access token for the Google Cloud AI Platform API.
 */
async function getAccessToken() {
  const client = auth.fromJSON({
    // Use the default service account key for Cloud Functions
    type: 'service_account',
    project_id: process.env.GCLOUD_PROJECT,
    private_key: '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n', // This will be replaced by the runtime
    client_email: `${process.env.GCLOUD_PROJECT}@appspot.gserviceaccount.com`
  });

  const accessToken = await client.getAccessToken();
  return accessToken.token;
}

module.exports = { getAccessToken };
