import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Hashes a plaintext password for storage/comparison against `User.password_hash`.
String hashPassword(String plainText) =>
    sha256.convert(utf8.encode(plainText)).toString();
