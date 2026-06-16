package com.proptech.gateway.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GatewayRoutesConfig {

    @Bean
    RouteLocator proptechRoutes(
            RouteLocatorBuilder builder,
            @Value("${gateway.routes.user-service:http://user-service:8081}") String userServiceUri,
            @Value("${gateway.routes.product-service:http://product-service:8082}") String productServiceUri,
            @Value("${gateway.routes.listing-service:http://listing-service:8083}") String listingServiceUri,
            @Value("${gateway.routes.order-service:http://order-service:8084}") String orderServiceUri,
            @Value("${gateway.routes.payment-service:http://payment-service:8085}") String paymentServiceUri
    ) {
        return builder.routes()
                .route("user-service", route -> route
                        .path("/api/users/**")
                        .uri(userServiceUri))
                .route("user-service-openapi", route -> route
                        .path("/v3/api-docs/user-service")
                        .filters(filter -> filter.rewritePath("/v3/api-docs/user-service", "/v3/api-docs"))
                        .uri(userServiceUri))
                .route("product-service", route -> route
                        .path("/api/products/**")
                        .uri(productServiceUri))
                .route("product-service-openapi", route -> route
                        .path("/v3/api-docs/product-service")
                        .filters(filter -> filter.rewritePath("/v3/api-docs/product-service", "/v3/api-docs"))
                        .uri(productServiceUri))
                .route("listing-service", route -> route
                        .path("/api/listings/**")
                        .uri(listingServiceUri))
                .route("listing-service-openapi", route -> route
                        .path("/v3/api-docs/listing-service")
                        .filters(filter -> filter.rewritePath("/v3/api-docs/listing-service", "/v3/api-docs"))
                        .uri(listingServiceUri))
                .route("order-service", route -> route
                        .path("/api/orders/**")
                        .uri(orderServiceUri))
                .route("order-service-openapi", route -> route
                        .path("/v3/api-docs/order-service")
                        .filters(filter -> filter.rewritePath("/v3/api-docs/order-service", "/v3/api-docs"))
                        .uri(orderServiceUri))
                .route("payment-service", route -> route
                        .path("/api/payments/**")
                        .uri(paymentServiceUri))
                .route("payment-service-openapi", route -> route
                        .path("/v3/api-docs/payment-service")
                        .filters(filter -> filter.rewritePath("/v3/api-docs/payment-service", "/v3/api-docs"))
                        .uri(paymentServiceUri))
                .build();
    }
}
