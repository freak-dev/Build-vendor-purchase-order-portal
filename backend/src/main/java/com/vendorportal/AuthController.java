package com.vendorportal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import java.util.Map;
@RestController
@RequestMapping("/api/auth")
class AuthController {
 private final AuthenticationManager manager;
 AuthController(AuthenticationManager manager){this.manager=manager;}
 record Credentials(@jakarta.validation.constraints.NotBlank String username,@jakarta.validation.constraints.NotBlank String password){}
 @PostMapping("/login") Map<String,Object> login(@Valid @RequestBody Credentials c){try{Authentication a=manager.authenticate(new UsernamePasswordAuthenticationToken(c.username(),c.password()));return Map.of("username",a.getName(),"roles",a.getAuthorities().stream().map(x->x.getAuthority()).toList());}catch(AuthenticationException e){throw new ResponseStatusException(HttpStatus.UNAUTHORIZED,"Invalid username or password");}}
 @PostMapping("/logout") @ResponseStatus(HttpStatus.NO_CONTENT) void logout(){}
}

