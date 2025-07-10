package com.example.api.controller;

import com.example.api.entity.*;
import com.example.api.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;

    @PostMapping("/checkout-from-cart")
    public ResponseEntity<?> checkoutFromCart(Authentication auth) {
        String username = auth.getName();

        /*
        //Kiểm tra vai trò là CLIENT - Chỉ CLIENT mới được đặt hàng
        boolean isClient = auth.getAuthorities().stream()
                .anyMatch(grantedAuthority -> grantedAuthority.getAuthority().equals("CLIENT"));
        if (!isClient) {
            return ResponseEntity.status(403).body("Chỉ người dùng CLIENT mới có quyền đặt hàng!");
        }
        * */
        List<CartItem> cartItems = cartItemRepository.findByUsername(username);

        if (cartItems.isEmpty()) {
            return ResponseEntity.badRequest().body("Giỏ hàng đang trống!");
        }

        // Kiểm tra tồn kho trước
        for (CartItem item : cartItems) {
            Product product = item.getProduct();
            if (item.getQuantity() > product.getStock()) {
                return ResponseEntity.badRequest().body("Không đủ hàng: " + product.getName());
            }
        }

        // Tạo đơn hàng
        Order order = Order.builder()
                .username(username)
                .createdAt(LocalDateTime.now())
                .build();

        List<OrderItem> orderItems = new ArrayList<>();
        double totalPrice = 0;

        for (CartItem item : cartItems) {
            Product product = item.getProduct();

            // Trừ tồn kho
            product.setStock(product.getStock() - item.getQuantity());
            productRepository.save(product);

            // Tạo OrderItem
            OrderItem orderItem = OrderItem.builder()
                    .product(product)
                    .quantity(item.getQuantity())
                    .unitPrice(product.getPrice())
                    .order(order)
                    .build();

            orderItems.add(orderItem);
            totalPrice += product.getPrice() * item.getQuantity();
        }

        // Gắn orderItems vào đơn hàng
        order.setOrderItems(orderItems);
        order.setTotalPrice(totalPrice);

        // Lưu đơn hàng và các item
        orderRepository.save(order); // cascade sẽ lưu luôn orderItems

        // Xoá giỏ hàng
        cartItemRepository.deleteByUsername(username);

        return ResponseEntity.ok("Đơn hàng đã được đặt thành công!");
    }
}
