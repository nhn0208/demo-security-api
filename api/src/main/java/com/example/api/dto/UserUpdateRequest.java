package com.example.api.dto;

import lombok.Data;

@Data
public class UserUpdateRequest {
    private String email;
    private String role;
    private String password;
}
