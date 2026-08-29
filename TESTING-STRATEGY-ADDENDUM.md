# Testing strategy addendum — TWITER (Twitter-to-Kafka microservices)

30-module reactive/event-driven microservices system. Spot-checked 5 core services (`gateway-service`, `twitter-to-kafka-service`, `kafka-to-elastic-service`, `elastic-query-service`, `analytics-service`) - every one already has real unit/integration test coverage on its central business logic (transformers, query services, listeners) from an earlier pass, same pattern as NEOBANK/zoo-nextjs/team-soccer-next/tortilleria-bendicion. A genuinely thorough audit of all 30 modules is beyond what this pass's remaining time allows - this is a scoped spot-check, not a full-system review.

## Found, not fixed - needs a judgment call this pass didn't make blind

`gateway-service`'s `WebSecurityConfig`:

```java
httpSecurity.authorizeExchange().anyExchange().permitAll();
httpSecurity.csrf().disable();
```

The API gateway - the single entry point routing to every backend microservice - has **no authentication or authorization at all**. Unlike the SecurityConfig bugs found and fixed in SISTEMA PARTIDOS and NEOBANK this same session (both had a *real* auth system that a specific guard failed to enforce correctly), this project has **no user/auth model anywhere** that was found during this pass - no login, no JWT, no session. The package naming (`com.microservices.demo`) and overall shape strongly resemble a well-known public microservices/event-driven-architecture course project, where implementing real authentication is typically out of scope by design (the focus is Kafka/Elasticsearch/service-discovery patterns, not access control). There's also a commented-out non-reactive `SecurityFilterChain` variant directly below the active one, suggesting someone was iterating on this, not that it was overlooked.

Given the real uncertainty about whether this is intentional (a demo/learning project) or a gap (if this is meant to front real user data), **this was not fixed**. Writing a real authentication system into a project that has none, unprompted, is a materially bigger and more presumptuous change than the SecurityConfig fixes made elsewhere this session (which each closed a gap in security infra that already existed and was clearly intended to work). Flagging it here for a decision: if this system is meant to be internet-facing with real user data, this needs real auth added; if it's a learning/demo project, this may be fine as-is.

**Also not written**: a test characterizing this behavior (e.g. confirming any path returns non-401/403). Attempted to scope one via `WebTestClient` but a full `@SpringBootTest` context for this module would also bring up Spring Cloud Gateway's service-discovery (Eureka) and circuit-breaker (Resilience4j) wiring, which commonly fails to start cleanly outside the full `docker-compose` stack this repo depends on (see `integration-test.yml`, added during the earlier CI/CD pass, which exists specifically because this system needs its full live stack to test meaningfully). Authoring an integration test for a context I can't verify actually boots - on top of the standing "don't execute" instruction for this pass - risked shipping something broken with no way to know. Recommended as a real follow-up once there's a decision on the security question above, ideally exercised through `integration-test.yml`'s existing full-stack setup rather than a narrower unverifiable slice test.

## Verification status

N/A - no new test files added for this project in this pass; the finding above is a documentation-only addition (this file).
