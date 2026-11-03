package com.vendorportal;

import org.springframework.context.annotation.*;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpMethod;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.userdetails.*;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.JdbcUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.boot.CommandLineRunner;

@Configuration
@EnableMethodSecurity
class SecurityConfig {
  @Bean PasswordEncoder passwordEncoder(){return new BCryptPasswordEncoder();}
  @Bean AuthenticationManager authenticationManager(AuthenticationConfiguration c) throws Exception { return c.getAuthenticationManager(); }
  @Bean UserDetailsService users(JdbcTemplate db){JdbcUserDetailsManager manager=new JdbcUserDetailsManager(db.getDataSource());manager.setUsersByUsernameQuery("SELECT username,password_hash,enabled FROM app_users WHERE username=? AND enabled=TRUE");manager.setAuthoritiesByUsernameQuery("SELECT username,CONCAT('ROLE_',role) FROM app_users WHERE username=? AND enabled=TRUE");return manager;}
  @Bean CorsConfigurationSource corsConfigurationSource(){
    CorsConfiguration config=new CorsConfiguration();
    String origins=System.getenv("APP_CORS_ORIGINS");
    if(origins!=null&&!origins.isBlank())config.setAllowedOrigins(java.util.Arrays.stream(origins.split(",")).map(String::trim).filter(s->!s.isEmpty()).toList());
    config.setAllowedMethods(java.util.List.of("GET","POST","PUT","PATCH","DELETE","OPTIONS"));
    config.setAllowedHeaders(java.util.List.of("Authorization","Content-Type"));
    config.setAllowCredentials(true);
    UrlBasedCorsConfigurationSource source=new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**",config);
    return source;
  }
  @Bean @Order(1) SecurityFilterChain loginFilter(HttpSecurity http) throws Exception {
    http.securityMatcher("/api/auth/login")
      .csrf(c->c.disable())
      .cors(Customizer.withDefaults())
      .authorizeHttpRequests(a->a.anyRequest().permitAll())
      .httpBasic(b->b.disable())
      .formLogin(f->f.disable());
    return http.build();
  }
  @Bean @Order(2) SecurityFilterChain filter(HttpSecurity http) throws Exception {http.csrf(c->c.disable()).cors(Customizer.withDefaults()).authorizeHttpRequests(a->a.requestMatchers("/actuator/health","/swagger-ui/**","/swagger-ui.html","/v3/api-docs/**").permitAll().requestMatchers(HttpMethod.OPTIONS,"/**").permitAll().requestMatchers("/api/dashboard","/api/vendors/**","/api/orders/**").hasAnyRole("ADMIN","PURCHASE_MANAGER","INVENTORY_MANAGER","VENDOR").requestMatchers("/api/products/**","/api/inventory/**","/api/alerts","/api/reports/**").hasAnyRole("ADMIN","PURCHASE_MANAGER","INVENTORY_MANAGER").requestMatchers("/api/**").authenticated().anyRequest().permitAll()).httpBasic(Customizer.withDefaults());return http.build();}
  @Bean CommandLineRunner bootstrap(JdbcTemplate db,PasswordEncoder encoder){return args->{String username=System.getenv().getOrDefault("ADMIN_USERNAME","admin");String password=System.getenv("ADMIN_PASSWORD");if(password!=null&&!password.isBlank()&&((Integer)db.queryForObject("SELECT COUNT(*) FROM app_users WHERE username=?",Integer.class,username))==0)db.update("INSERT INTO app_users(username,password_hash,role) VALUES(?,?,'ADMIN')",username,encoder.encode(password));};}
}
