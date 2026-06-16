package com.proptech.gateway.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    OpenAPI gatewayServiceOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("PropTech Gateway API")
                        .version("v1")
                        .description("API gateway entry point and aggregated Swagger UI for PropTech services."));
    }
}
