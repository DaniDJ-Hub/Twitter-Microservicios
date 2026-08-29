TWITTER STREAM ANALYTICS — Event-Driven Microservices with Kafka, Elasticsearch & Full Observability

**Streaming Ingestion Pipeline**: I built a pipeline that ingests live tweets via the Twitter streaming API (Twitter4J), publishes them to Kafka, processes them through a Kafka Streams application, and fans out to two independent consumers: one indexing into Elasticsearch for full-text search, another persisting aggregated analytics to Postgres — so search and analytics scale and fail independently of each other.

**Both Query Styles, Same Data**: I built the Elasticsearch query layer twice on purpose — a classic blocking Spring MVC service + Thymeleaf web client, and a fully reactive Spring WebFlux equivalent (`reactive-elastic-query-service` / `-web-client`) — sharing the same Elasticsearch model/index-client libraries, to compare both approaches against identical data.

**Netflix-OSS-Style Platform Services**: I set up centralized configuration (Spring Cloud Config Server, backed by its own config repo), service discovery (Eureka), and a Spring Cloud Gateway edge service — with an alternate `servicesAdvance` Docker Compose topology that runs 2 gateway replicas, 2 discovery replicas, and an HA config server pairing to demonstrate the platform under horizontal scaling.

**Keycloak-Secured Analytics API**: I secured `analytics-service` as an OAuth2 resource server with audience validation (`AudienceValidator`) against a Keycloak realm, transforming Avro-encoded Kafka events into persisted entities and exposing them through a JWT-protected REST API.

**Full Observability Stack**: I wired in Prometheus + Grafana for metrics and Zipkin (its own MySQL-backed store) for distributed tracing across every service, plus a Redis cluster (master/replica) for shared caching — all provisioned through Docker Compose alongside the application services.

**Load-Tested, Not Just Demoed**: two JMeter plans — one unauthenticated health-check sweep across every service's actuator endpoint, and one realistic authenticated flow that pulls a Keycloak token and drives elastic-query-service, analytics-service, and kafka-streams-service through the gateway.

Technologies: Java 17, Spring Boot 3.1 (Spring Cloud Gateway, Config, Eureka, Spring WebFlux), Apache Kafka + Kafka Streams, Twitter4J, Elasticsearch, PostgreSQL, Keycloak (OAuth2), Redis (cluster), Prometheus + Grafana, Zipkin, Docker Compose, JMeter.
