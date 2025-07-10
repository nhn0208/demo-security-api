package com.example.api.controller;

import com.example.api.entity.Product;
import com.example.api.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductRepository productRepository;

    @GetMapping("/all")
    public List<Product> getAll() {
        return productRepository.findAll();
    }
}
