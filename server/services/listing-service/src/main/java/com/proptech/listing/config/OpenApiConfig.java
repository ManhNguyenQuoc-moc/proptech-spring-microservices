package com.proptech.listing.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    OpenAPI listingServiceOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("PropTech Listing Service API")
                        .version("v1")
                        .description("Listing domain API for the PropTech platform."));
    }
}
