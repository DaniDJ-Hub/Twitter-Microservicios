package com.microservices.demo.mdc.config;

import com.microservices.demo.mdc.interceptor.MDCHandlerInterceptor;
import org.junit.jupiter.api.Test;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

class WebMvcConfigTest {

    @Test
    void addInterceptors_registersTheMdcHandlerInterceptor() {
        MDCHandlerInterceptor interceptor = mock(MDCHandlerInterceptor.class);
        InterceptorRegistry registry = mock(InterceptorRegistry.class, org.mockito.Answers.RETURNS_DEEP_STUBS);

        new WebMvcConfig(interceptor).addInterceptors(registry);

        verify(registry).addInterceptor(interceptor);
    }
}
