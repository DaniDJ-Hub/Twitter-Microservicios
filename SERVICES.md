# Twitter Stream Analytics — Service Descriptions

## Platform services
- **config-server** — Spring Cloud Config Server; every other service pulls its configuration from here at startup (backed by `config-server-repository`).
- **discovery-service** — Eureka server for service registration/discovery.
- **gateway-service** — Spring Cloud Gateway; single entry point routing to the query/analytics services, integrated with Eureka for routing and Keycloak for auth.

## Ingestion & streaming
- **twitter-to-kafka-service** — connects to the Twitter streaming API (Twitter4J) and publishes incoming tweets to Kafka via the shared `kafka-producer`/`kafka-model` libraries.
- **kafka-streams-service** — Kafka Streams topology processing the raw tweet stream (stateful, local state store under `kafka-streaming-state`).
- **kafka-to-elastic-service** — Kafka consumer that indexes processed tweets into Elasticsearch.
- **analytics-service** — Kafka consumer that transforms Avro-encoded events into DB entities and persists them; exposes a JWT-secured (Keycloak, audience-validated) REST API over the aggregated analytics.

## Query & presentation
- **elastic-query-service** / **elastic-query-web-client** — blocking (Spring MVC) REST API over Elasticsearch + a Thymeleaf web client consuming it.
- **reactive-elastic-query-service** / **reactive-elastic-query-web-client** — the same query capability built on Spring WebFlux instead, sharing the `elastic-query-service-common` / `elastic-query-web-client-common` modules with the blocking versions.

## Shared libraries
- **kafka/** (`kafka-admin`, `kafka-consumer`, `kafka-producer`, `kafka-model`) — Kafka client setup and Avro-generated message models shared by every producer/consumer.
- **elastic/** (`elastic-config`, `elastic-model`, `elastic-index-client`, `elastic-query-client`) — Elasticsearch client configuration and index/query models shared by both query-service pairs.
- **app-config-data**, **common-config**, **common-util**, **mdc-interceptor** — shared Spring Cloud Config bindings, common utilities, and an MDC interceptor for consistent request-tracing log context across services.

## Infrastructure (Docker Compose)
Composable stack: Kafka cluster, Elasticsearch cluster, Postgres, Redis cluster, a Keycloak authorization server, Zipkin (with its own MySQL store) for tracing, and Prometheus + Grafana for metrics. `services.yml` runs the single-instance topology; `servicesAdvance.yml` runs an HA variant (2 gateway + 2 discovery + paired config-server instances).

## jmeter
`health-check-load-test.jmx` — unauthenticated sweep of every service's `/actuator/health`. `gateway-query-flow-load-test.jmx` — authenticates against Keycloak, then drives elastic-query-service, analytics-service, and kafka-streams-service through the gateway.
