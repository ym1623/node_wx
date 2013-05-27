var crypto = require('crypto')
;

/**
 * This code has originally been taken from:
 * http://comments.gmane.org/gmane.comp.lang.javascript.nodejs/2378
 *
 * Posted by Marak Squires.
 *
 * RandomString returns a pseudo-random ASCII string
 * which contains at least the specified number of bits of entropy.
 * The returned value is a string of length ⌈bits/6⌉ of characters
 * from the base64url alphabet.
 */
function randomString(bits) {
  var rand
  , i
  , chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
  , ret=''
  ;
  // in v8, Math.random() yields 32 pseudo-random bits (in spidermonkey it gives 53)
  while(bits > 0){
    rand=Math.floor(Math.random()*0x100000000); // 32-bit integer
    // base 64 means 6 bits per character,
    // so we use the top 30 bits from rand to give 30/6=5 characters.
    for(i=26; i>0 && bits>0; i-=6, bits-=6) ret+=chars[0x3F & rand >>> i]
  }
  return ret
};

/**
 * Returns dump of the given JSON obj as a str.
 * There is no encryption, and it might not be safe.
 * Might throw an error.
 *
 * Arguments:
 *  - obj: JSON obj.
 *
 */
exports.stringify = function(obj) {
  return new Buffer(JSON.stringify(obj), 'utf8').toString('base64');
};

/**
 * Returns obj loaded from given string.
 * Might throw an error.
 *
 * Arguments:
 *  - str: string representation of obj to load.
 *
 */
exports.parse = function(str) {
  return JSON.parse(new Buffer(str, 'base64').toString('utf8'));
};

/**
 * Return base64url signed sha1 hash of str using key
 */
function signStr(str, key) {
  var hmac = crypto.createHmac('sha1', key);
  hmac.update(str);
  return hmac.digest('base64').replace(/\+/g, '-').replace(/\//g, '_');
};


var CYPHER = 'aes256';
var CODE_ENCODING = "hex";
var DATA_ENCODING = "utf8";

/**
 * Return str representing the given obj. It is signed and encrypted using the
 * given keys.
 */
exports.secureStringify = function(obj, encrypt_key, validate_key) {
  // TODO XXX: check the validity of the process
  // Do we need some timestamp to invalidate too old data?
  var nonce_check = randomString(48); // 8 chars
  var nonce_crypt = randomString(48); // 8 chars
  var cypher = crypto.createCipher(CYPHER, encrypt_key + nonce_crypt);
  var data = JSON.stringify(obj);
  var res = cypher.update(nonce_check, DATA_ENCODING, CODE_ENCODING);
  res += cypher.update(data, DATA_ENCODING, CODE_ENCODING);
  res += cypher.final(CODE_ENCODING);
  var digest = signStr(data, validate_key + nonce_check);
  return digest + nonce_crypt + res;
};

/**
 * Given a string resulting from secureStringify, load corresponding JSON.
 */
exports.secureParse = function(str, encrypt_key, validate_key) {
  var expected_digest = str.substring(0, 28);
  var nonce_crypt = str.substring(28, 36);
  var encrypted_data = str.substring(36, str.length);
  var decypher = crypto.createDecipher(CYPHER, encrypt_key + nonce_crypt);
  var data = decypher.update(encrypted_data, CODE_ENCODING, DATA_ENCODING);
  data += decypher.final(DATA_ENCODING);
  var nonce_check = data.substring(0, 8);
  data = data.substring(8, data.length);
  var digest = signStr(data, validate_key + nonce_check);
  if(digest != expected_digest) throw new Error("Bad digest");
  return JSON.parse(data);
};

/**
 * Class to store encryption/validation keys in a more convenient way.
 */
function SecureSerializer(encrypt_key, validate_key) {
  this.encrypt_key = encrypt_key;
  this.validate_key = validate_key;
};

SecureSerializer.prototype = {
  stringify: function(obj) {
    return exports.secureStringify(obj, this.encrypt_key, this.validate_key);
  },
  parse: function(str) {
    return exports.secureParse(str, this.encrypt_key, this.validate_key);
  }
};

exports.createSecureSerializer = function(encrypt_key, validate_key) {
  return new SecureSerializer(encrypt_key, validate_key);
}

exports.randomString = randomString;
