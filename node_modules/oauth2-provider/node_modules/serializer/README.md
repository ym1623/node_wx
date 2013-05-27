# Serializer

This module provides function to go from JSON obj to [opaque] string or vice & versa.

 - stringify(obj): Returns dump of the given JSON obj as a str. There is no encryption, and it might not be safe. Might throw an error.
 - parse(str): Returns obj loaded from given string (result of dump_str function). Might throw an error.
 - [signStr(str, key): Returns base64url signed sha1 hash of str using key.]
 - secureStringify(obj, encrypt_key, validate_key): Return str representing the given obj. It is signed and encrypted using the given keys.
 - secureParse(str, encrypt_key, validate_key): Given a string resulting from dump_secure_str, load corresponding JSON.
 - createSecureSerializer(encrypt_key, validate_key): Return class to store encryption/validation keys in a more convenient way. The object created will have the methods parse(obj) and stringify(str) corresponding to secureParse and secureStringify.

The cypher used is aes256, the crypted data are in hex. The signing process uses HMAC with SHA1.

## Tests

    $> npm install vows
    $> vows test_serializer.js  --spec

## Credits

Extracted from [nodetk](https://github.com/AF83/nodetk).

Original author: Pierre Ruyssen

## License

BSD
