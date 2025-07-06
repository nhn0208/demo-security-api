package com.example.api.controller;

import com.example.api.entity.CartItem;
import com.example.api.entity.Product;
import com.example.api.repository.CartItemRepository;
import com.example.api.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;

    @PostMapping("/add")
    public ResponseEntity<?> addToCart(@RequestParam Long productId, @RequestParam int quantity, Authentication auth) {
        String username = auth.getName();

        Optional<Product> productOpt = productRepository.findById(productId);
        if (productOpt.isEmpty()) return ResponseEntity.badRequest().body("Sản phẩm không tồn tại");

        CartItem item = CartItem.builder()
                .username(username)
                .product(productOpt.get())
                .quantity(quantity)
                .build();

        cartItemRepository.save(item);
        return ResponseEntity.ok("Đã thêm vào giỏ hàng");
    }

    @GetMapping
    public List<CartItem> viewCart(Authentication auth) {
        return cartItemRepository.findByUsername(auth.getName());
    }

    @DeleteMapping("/clear")
    public ResponseEntity<?> clearCart(Authentication auth) {
        cartItemRepository.deleteByUsername(auth.getName());
        return ResponseEntity.ok("🗑Đã xóa toàn bộ giỏ hàng");
    }
}
