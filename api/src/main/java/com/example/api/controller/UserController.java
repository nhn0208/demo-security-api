package com.example.api.controller;

import com.example.api.dto.UserUpdateRequest;
import com.example.api.entity.Role;
import com.example.api.entity.User;
import com.example.api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserRepository userRepository;

    // Khong kiem tra auth
//    @GetMapping("/{id}")
//    public Optional<User> getUserById(@PathVariable Long id) {
//        return userRepository.findById(id);
//    }

    // kiem tra auth
    @GetMapping("/{id}")
    public ResponseEntity<?> getUserById(@PathVariable Long id, Authentication auth) {
        Optional<User> user = userRepository.findById(id);
        if (user.isEmpty()) return ResponseEntity.notFound().build();

        String currentUsername = auth.getName();
        if (!user.get().getUsername().equals(currentUsername)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access Denied");
        }

        return ResponseEntity.ok(user);
    }



    @GetMapping("/me")
    public Optional<User> getCurrentUser(Authentication auth) {
        String username = auth.getName();
        return userRepository.findByUsername(username);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(
            @PathVariable Long id,
            @RequestBody UserUpdateRequest updateRequest,
            Authentication auth
    ) {
        Optional<User> userOpt = userRepository.findById(id);
        if (userOpt.isEmpty()) return ResponseEntity.notFound().build();

        User user = userOpt.get();

        String currentUsername = auth.getName();

        if (user.getUsername().equals(currentUsername)) {
            user.setEmail(updateRequest.getEmail());
        }
        else if (auth.getAuthorities().stream().anyMatch(
                a -> a.getAuthority().equals("ROLE_ADMIN"))) {

            user.setEmail(updateRequest.getEmail());

            try {
                Role newRole = Role.valueOf(updateRequest.getRole());
                user.setRole(newRole);
            } catch (IllegalArgumentException e) {
                return ResponseEntity.badRequest().body("Invalid role");
            }
        }
        else {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("Bạn không có quyền sửa thông tin người khác.");
        }

        userRepository.save(user);
        return ResponseEntity.ok("User updated");
    }


}
