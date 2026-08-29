COMPOSE_PATH_SEPARATOR=:
# zipkin.yml is required: kafka-streams-service depends_on zipkin. monitoring.yml
# (grafana/prometheus) is optional observability tooling, included for consistency.
COMPOSE_FILE=common.yml:kafka_cluster.yml:elastic_cluster.yml:redis_cluster.yml:monitoring.yml:zipkin.yml:services.yml
KAFKA_VERSION=7.3.0
ELASTIC_VERSION=7.17.4
KEYCLOAK_VERSION=15.0.1
REDIS_VERSION=6.0.5
GRAFANA_VERSION=5.4.3
PROMETHEUS_VERSION=v2.19.2
ZIPKIN_VERSION=2.22.2
SERVICE_VERSION=0.0.1-SNAPSHOT
GLOBAL_NETWORK=application
GROUP_ID=com.microservices.demo
ENCRYPT_KEY=your-encryption-key-here
TWITTER_BEARER_TOKEN=your-twitter-bearer-token-here



# Local Environment Variables for Development
# Copy this to .env.local for local development

# Spring Profile
SPRING_PROFILES_ACTIVE=local

# Server Configuration
SERVER_PORT=8187
SERVER_SERVLET_CONTEXT_PATH=/

# Spring Cloud Config
SPRING_CLOUD_CONFIG_URI=http://localhost:8888

# OAuth2 Security (Local Keycloak)
SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI=http://localhost:9091/auth/realms/microservices-realm
SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI=http://localhost:9091/auth/realms/microservices-realm/protocol/openid-connect/certs

# Kafka Configuration (Local)
KAFKA_CONFIG_BOOTSTRAP_SERVERS=localhost:19092,localhost:29092,localhost:39092
KAFKA_CONFIG_SCHEMA_REGISTRY_URL=http://localhost:8081
SPRING_KAFKA_BOOTSTRAP_SERVERS=localhost:9092

# Kafka Streams
# See docker-compose/.env for why this is a relative path, not ${HOME}/...
KAFKA_STREAMS_STATE_FILE_LOCATION=./kafka-streaming-state

# Eureka Discovery (Local)
EUREKA_CLIENT_SERVICE_URL_DEFAULT_ZONE=http://localhost:8761/eureka/

# Zipkin and Tracing (Local)
MANAGEMENT_ZIPKIN_TRACING_ENDPOINT=http://localhost:9411/api/v2/spans
MANAGEMENT_TRACING_SAMPLING_PROBABILITY=1.0

# Logging Levels (More verbose for local development)
LOGGING_LEVEL_COM_MICROSERVICES_DEMO=DEBUG
LOGGING_LEVEL_ROOT=INFO
LOGGING_LEVEL_KAFKA=DEBUG
LOGGING_LEVEL_TRACING=DEBUG
LOGGING_LEVEL_ZIPKIN=DEBUG
LOGGING_LEVEL_BRAVE=DEBUG