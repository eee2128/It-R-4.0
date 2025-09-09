const { GoogleAuth } = require('google-auth-library');

/**
 * Gets an access token for the Google Cloud AI Platform API.
 */
async function getAccessToken() {
  console.log('Requesting Google Cloud access token...');
  const auth = new GoogleAuth({
    scopes: 'https://www.googleapis.com/auth/cloud-platform'
  });

  try {
    const client = await auth.getClient();
    const accessToken = await client.getAccessToken();
    console.log('Successfully obtained access token.');
    return accessToken.token;
  } catch (error) {
    console.error('Failed to get access token:', error);
    throw new Error('Could not get Google Cloud access token. Please check the function logs.');
  }
}

module.exports = { getAccessToken };
