package com.example.api.configuration;

import com.example.api.entity.Product;
import com.example.api.entity.Role;
import com.example.api.entity.User;
import com.example.api.repository.ProductRepository;
import com.example.api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {
    private final UserRepository userRepo;
    private final ProductRepository productRepository;
    private final PasswordEncoder encoder;

    @Override
    public void run(String... args) {
        if (userRepo.count() == 0) {
            userRepo.save(User.builder()
                    .username("admin")
                    .email("admin@example.com")
                    .password(encoder.encode("admin123"))
                    .role(Role.ADMIN)
                    .build());

            userRepo.save(User.builder()
                    .username("client")
                    .email("client@example.com")
                    .password(encoder.encode("client123"))
                    .role(Role.CLIENT)
                    .build());
        }
        if (productRepository.count() == 0) {
            productRepository.saveAll(List.of(
                    Product.builder().name("MacBook Pro").description("Apple Laptop").price(2500).stock(10).build(),
                    Product.builder().name("iPhone 15").description("Apple Phone").price(1200).stock(50).build(),
                    Product.builder().name("AirPods Pro").description("Wireless earbuds").price(250).stock(100).build()
            ));
            System.out.println("✅ Seeded product data.");
        }
    }
}
