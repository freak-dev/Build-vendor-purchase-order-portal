package com.vendorportal;

import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import static org.junit.jupiter.api.Assertions.*;

class PasswordHashTest {
  @Test void storesPasswordsAsNonReversibleHashes() {
    BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
    String raw = "academic-demo-password";
    String hash = encoder.encode(raw);
    assertNotEquals(raw, hash);
    assertTrue(encoder.matches(raw, hash));
    assertFalse(encoder.matches("wrong-password", hash));
  }
}
