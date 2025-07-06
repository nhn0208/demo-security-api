package com.example.api.service;

import com.example.api.dto.*;
import com.example.api.entity.Role;
import com.example.api.entity.User;
import com.example.api.repository.UserRepository;
import com.example.api.configuration.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.*;
import org.springframework.security.core.userdetails.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final UserRepository userRepo;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authManager;

    public TokenResponse register(RegisterRequest request) {
        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(Role.valueOf(request.getRole()))
                .build();
        userRepo.save(user);
        String token = jwtService.generateToken(user);
        return new TokenResponse(token);
    }

    public TokenResponse login(LoginRequest request) {
        authManager.authenticate(new UsernamePasswordAuthenticationToken(
                request.getUsername(), request.getPassword()
        ));
        User user = userRepo.findByUsername(request.getUsername()).orElseThrow();
        System.out.println("Username : " + user.getUsername() + "\nRole : " + user.getRole());
        String token = jwtService.generateToken(user);
        return new TokenResponse(token);
    }
}
