const crypto = require('crypto');

// Environment variable for the master key (must be exactly 32 bytes/characters for AES-256)
// In production, this MUST be set via environment variable.
const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || 'default_secret_key_32_chars_long!'; // 32 chars
const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 16; // AES block size
const SALT_LENGTH = 64;
const TAG_LENGTH = 16;

/**
 * Encrypts a string (e.g., an OAuth token) using AES-256-GCM.
 * @param {string} text The text to encrypt.
 * @returns {string} The encrypted format: iv:salt:authTag:encryptedText
 */
function encrypt(text) {
  if (!text) return null;

  const iv = crypto.randomBytes(IV_LENGTH);
  const salt = crypto.randomBytes(SALT_LENGTH);

  // Deriving key using pbkdf2 to add extra security, even though we have a 32 byte key.
  const key = crypto.pbkdf2Sync(ENCRYPTION_KEY, salt, 100000, 32, 'sha512');

  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
  
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  const authTag = cipher.getAuthTag();

  return `${iv.toString('hex')}:${salt.toString('hex')}:${authTag.toString('hex')}:${encrypted}`;
}

/**
 * Decrypts a previously encrypted string.
 * @param {string} encryptedData The encrypted string in format: iv:salt:authTag:encryptedText
 * @returns {string} The decrypted plaintext token.
 */
function decrypt(encryptedData) {
  if (!encryptedData) return null;

  try {
    const parts = encryptedData.split(':');
    if (parts.length !== 4) throw new Error('Invalid encrypted data format');

    const iv = Buffer.from(parts[0], 'hex');
    const salt = Buffer.from(parts[1], 'hex');
    const authTag = Buffer.from(parts[2], 'hex');
    const encryptedText = parts[3];

    const key = crypto.pbkdf2Sync(ENCRYPTION_KEY, salt, 100000, 32, 'sha512');

    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
    decipher.setAuthTag(authTag);

    let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
    decrypted += decipher.final('utf8');

    return decrypted;
  } catch (error) {
    console.error('Decryption failed:', error.message);
    throw new Error('Decryption failed');
  }
}

module.exports = {
  encrypt,
  decrypt
};
