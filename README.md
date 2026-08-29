# Twitter Stream Analytics — Microservicios Event-Driven

Plataforma de **analítica de streams en tiempo real** construida como un sistema de
microservicios orientado a eventos. Ingiere tweets desde la API de streaming de Twitter,
los publica en Kafka, los procesa con Kafka Streams y los reparte hacia dos consumidores
independientes: uno que **indexa en Elasticsearch** (búsqueda full-text) y otro que
**persiste analítica agregada en PostgreSQL** y la expone vía una API REST protegida con
JWT (Keycloak).

Todo el stack —brokers, índices, base de datos, autorización, trazas y métricas— se
levanta con Docker Compose.

---

## 1. ¿De qué trata?

```
Twitter Streaming API (Twitter4J)
            │
            ▼
  twitter-to-kafka-service ──► Kafka (Avro + Schema Registry)
                                  │
                                  ▼
                        kafka-streams-service   (topología de procesamiento, state store RocksDB)
                                  │
                    ┌─────────────┴──────────────┐
                    ▼                            ▼
        kafka-to-elastic-service        analytics-service
                    │                            │
                    ▼                            ▼
             Elasticsearch                  PostgreSQL
                    │                            │
                    ▼                            ▼
      elastic-query-service            API REST analítica
      reactive-elastic-query-service   (OAuth2 Resource Server)
                    │                            │
                    └────────► gateway-service ◄─┘
                                  ▲
                          Keycloak (JWT) + Eureka + Config Server
```

Puntos de diseño relevantes:

- **Capa de consulta implementada dos veces a propósito**: una versión bloqueante
  (Spring MVC + cliente web Thymeleaf) y una versión reactiva equivalente
  (Spring WebFlux), compartiendo las mismas librerías de modelo/cliente Elasticsearch,
  para comparar ambos enfoques sobre datos idénticos.
- **Seguridad zero-trust**: el gateway solo enruta; la validación del JWT (con validación
  de *audience* propia por servicio, `AudienceValidator`) ocurre en cada servicio
  protegido de forma independiente.
- **Resiliencia en el borde**: circuit breaker (Resilience4j) y rate limiter por usuario
  (Redis) aplicados en las rutas del gateway, con endpoints de fallback dedicados.
- **Observabilidad completa**: Prometheus + Grafana para métricas, Zipkin para trazas
  distribuidas, e interceptor MDC para correlación de logs entre servicios.

---

## 2. Servicios y módulos

### Plataforma

| Módulo | Rol |
|---|---|
| `config-server` | Spring Cloud Config Server. Sirve la configuración de todos los servicios (backend `native`, desde `config-server-repository/`). |
| `discovery-service` | Servidor Eureka para registro y descubrimiento. |
| `gateway-service` | Spring Cloud Gateway. Punto de entrada único, con circuit breaker y rate limiting. |

### Ingesta y streaming

| Módulo | Rol |
|---|---|
| `twitter-to-kafka-service` | Conecta a la API de streaming de Twitter (Twitter4J) y publica tweets en Kafka. Soporta modo *mock*. |
| `kafka-streams-service` | Topología de Kafka Streams sobre el stream de tweets (con state store local). |
| `kafka-to-elastic-service` | Consumidor Kafka que indexa los tweets procesados en Elasticsearch. |
| `analytics-service` | Consumidor Kafka que transforma eventos Avro en entidades y las persiste; expone API REST protegida con JWT. |

### Consulta y presentación

| Módulo | Rol |
|---|---|
| `elastic-query-service` | API REST bloqueante (Spring MVC) sobre Elasticsearch. Incluye un panel frontend en TypeScript vanilla (`frontend/`). |
| `elastic-query-web-client` / `-2` | Cliente web Thymeleaf que consume la API anterior. |
| `reactive-elastic-query-service` | Misma capacidad de consulta sobre Spring WebFlux. |
| `reactive-elastic-query-web-client` | Cliente web reactivo. |

### Librerías compartidas

`kafka/` (`kafka-admin`, `kafka-consumer`, `kafka-producer`, `kafka-model`) ·
`elastic/` (`elastic-config`, `elastic-model`, `elastic-index-client`, `elastic-query-client`) ·
`app-config-data` · `common-config` · `common-util` · `mdc-interceptor` ·
`elastic-query-service-common` · `elastic-query-web-client-common`

Detalle ampliado en [SERVICES.md](SERVICES.md).

---

## 3. Tecnologías utilizadas

| Categoría | Tecnología |
|---|---|
| Lenguaje / runtime | **Java 17**, Maven (multi-módulo, ~28 módulos) |
| Framework | **Spring Boot 3.1.2**, Spring MVC, **Spring WebFlux** |
| Spring Cloud 2022.0.4 | Config Server, Eureka (discovery), Gateway, Circuit Breaker (Resilience4j) |
| Mensajería | **Apache Kafka** (modo KRaft) + **Kafka Streams** 3.5.1, Confluent **Schema Registry**, **Avro** 1.11.2 |
| Búsqueda | **Elasticsearch 7.17.4** + Kibana |
| Base de datos | **PostgreSQL** (analítica y Keycloak), MySQL (almacenamiento de Zipkin) |
| Caché | **Redis** (master/replica), usado por el rate limiter del gateway |
| Seguridad | **Keycloak** (OAuth2 / OIDC), Spring Security Resource Server, validación de audiencia JWT |
| Observabilidad | **Prometheus**, **Grafana**, **Zipkin** (Micrometer Tracing + Brave), Logback + logstash-encoder, interceptor MDC |
| Ingesta externa | **Twitter4J** 4.0.7 |
| API docs | springdoc-openapi (anotaciones Swagger v3 en los controladores) |
| Frontend | Thymeleaf (clientes web) + un panel en TypeScript vanilla sin frameworks |
| Infraestructura | **Docker Compose** (stack componible por archivos), imágenes construidas con Cloud Native Buildpacks (`spring-boot:build-image`) |
| Pruebas de carga | **JMeter** (2 planes) + colección **Postman** |
| CI | GitHub Actions: build + tests unitarios, CodeQL, y un workflow de tests de integración contra el stack completo |

---

## 4. Requisitos previos

| Herramienta | Versión | Verificación |
|---|---|---|
| JDK | **17** (el proyecto compila con `java.version=17`) | `java -version` |
| Maven | 3.8+ | `mvn -v` |
| Docker Desktop | con Docker Compose v2 | `docker compose version` |
| Node.js | 18+ (solo si vas a compilar el panel `frontend/`) | `node -v` |
| JMeter | 5.6.3 (opcional, pruebas de carga) | `jmeter -v` |

> **Recursos:** el stack completo levanta Kafka, 3 nodos de Elasticsearch, Kibana,
> PostgreSQL, Keycloak, Redis, Zipkin + MySQL, Prometheus, Grafana y 8 microservicios.
> Asigna al menos **8 GB de RAM** a Docker Desktop.

---

## 5. Ejecución paso a paso (Docker Compose — recomendado)

### Paso 1 — Configurar credenciales

Edita `twitter-to-kafka-service/src/main/resources/twitter4j.properties` con tus claves
de la API de Twitter:

```properties
debug=true
oauth.consumerKey=TU_CONSUMER_KEY
oauth.consumerSecret=TU_CONSUMER_SECRET
oauth.accessToken=TU_ACCESS_TOKEN
oauth.accessTokenSecret=TU_ACCESS_TOKEN_SECRET
```

> ¿Sin credenciales de Twitter? El servicio trae `enable-mock-tweets: true` en su
> `application.yml`, que genera tweets sintéticos y permite probar todo el pipeline
> sin conectarse a Twitter.

### Paso 2 — Configurar las variables de entorno

En `docker-compose/.env`, sustituye los marcadores de posición:

```env
ENCRYPT_KEY=<una-clave-de-cifrado-propia>     # clave de cifrado de propiedades de Spring Cloud Config
TWITTER_BEARER_TOKEN=<tu-bearer-token>
```

La variable `COMPOSE_FILE` del mismo archivo define qué se levanta. Por defecto:

```
common.yml:kafka_cluster.yml:elastic_cluster.yml:redis_cluster.yml:postgres.yml:monitoring.yml:zipkin.yml:services.yml
```

Puedes quitar `monitoring.yml` si no necesitas Prometheus/Grafana, o cambiar
`services.yml` por `servicesAdvance.yml` para la topología HA (2 gateways, 2 Eureka,
config server pareado).

### Paso 3 — Compilar el proyecto

Desde la raíz del repositorio:

```bash
mvn clean install -DskipTests
```

### Paso 4 — Construir las imágenes Docker de los servicios

`services.yml` referencia imágenes ya construidas (`${GROUP_ID}/<servicio>:${SERVICE_VERSION}`),
así que hay que generarlas con Buildpacks antes de levantar el stack:

```bash
for svc in analytics-service config-server discovery-service elastic-query-service \
           elastic-query-web-client kafka-streams-service kafka-to-elastic-service \
           twitter-to-kafka-service gateway-service; do
  mvn -B -ntp -pl "$svc" -am spring-boot:build-image -DskipTests
done
```

En PowerShell:

```powershell
$servicios = @('analytics-service','config-server','discovery-service','elastic-query-service',
               'elastic-query-web-client','kafka-streams-service','kafka-to-elastic-service',
               'twitter-to-kafka-service','gateway-service')
foreach ($s in $servicios) { mvn -B -ntp -pl $s -am spring-boot:build-image -DskipTests }
```

### Paso 5 — Levantar el stack

```bash
cd docker-compose
docker compose up -d
```

El arranque es escalonado mediante healthchecks y los scripts `check-*.sh`
(config-server, Kafka, Keycloak, Postgres). La primera vez tarda varios minutos.

### Paso 6 — Verificar

```bash
docker compose ps                                   # todos los contenedores en estado healthy
curl http://localhost:8762                          # Eureka: servicios registrados
curl http://localhost:8890/actuator/health          # Config Server
curl http://localhost:9200/_cluster/health          # Elasticsearch
curl http://localhost:9092/actuator/health          # Gateway
```

### Paso 7 — Obtener un token y llamar a las APIs

```bash
curl -X POST 'http://localhost:9091/auth/realms/microservices-realm/protocol/openid-connect/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'username=app_super_user' \
  --data-urlencode 'password=app_super_user!' \
  --data-urlencode 'grant_type=password' \
  --data-urlencode 'client_id=elastic-query-web-client' \
  --data-urlencode 'client_secret=851a125f-7914-47da-bbeb-ec528c1755a6'
```

Usa el `access_token` devuelto como `Authorization: Bearer <token>` contra el gateway.
La colección [twitter-analytics.postman_collection.json](twitter-analytics.postman_collection.json)
ya trae este flujo completo.

### Paso 8 — Detener

```bash
docker compose down          # detener
docker compose down -v       # detener y borrar volúmenes (Elasticsearch, Postgres, Zipkin)
```

---

## 6. Puertos y URLs

| Servicio | URL / puerto host |
|---|---|
| Gateway | http://localhost:9092 |
| Eureka (discovery) | http://localhost:8762 |
| Config Server | http://localhost:8890 |
| Keycloak | http://localhost:9091 (admin/admin) |
| elastic-query-service | http://localhost:8189 |
| elastic-query-web-client | http://localhost:8190/elastic-query-web-client |
| kafka-streams-service | http://localhost:8187 |
| analytics-service | http://localhost:8188 |
| Elasticsearch | http://localhost:9200 |
| Kibana | http://localhost:5601 |
| Kafka UI | http://localhost:8087 |
| Schema Registry | http://localhost:8083 |
| Zipkin | http://localhost:9415 |
| Prometheus | http://localhost:9095 |
| Grafana | http://localhost:3011 (admin/admin) |
| Redis (master / replica) | 6383 / 6380 |

Kafka y PostgreSQL **no publican puertos al host**: solo son accesibles dentro de la red
Docker (`application`), por los nombres de servicio `kafka` y `postgres`.

Cada microservicio expone además un puerto de depuración remota (5005–5016), mapeado en
`services.yml`.

Las contraseñas por defecto de Keycloak, Postgres y Grafana son los valores estándar de
quickstart de cada imagen; están pensadas **solo para desarrollo local**.

---

## 7. Ejecución local sin Docker (solo infraestructura en contenedores)

Útil para depurar un servicio desde el IDE:

```bash
cd docker-compose
# Levanta solo la infraestructura
docker compose -f common.yml -f kafka_cluster.yml -f elastic_cluster.yml \
               -f redis_cluster.yml -f postgres.yml -f zipkin.yml \
               -f keycloak_authorization_server.yml up -d
```

Luego arranca los servicios en este orden (`mvn spring-boot:run -pl <módulo>` o desde el IDE):

1. `config-server` (8888)
2. `discovery-service` (8761)
3. `gateway-service` (9092)
4. el resto de servicios

Las variables para este modo están en `docker-compose/dev-env.sh`. Ten en cuenta que
algunas de ellas quedaron desactualizadas respecto a `kafka_cluster.yml`: apuntan a
`localhost:19092,29092,39092` (el antiguo clúster de 3 brokers), mientras que hoy Kafka
corre en un único nodo KRaft que **no publica puerto al host**. Si vas a ejecutar
servicios fuera de Docker, publica el puerto de Kafka en `kafka_cluster.yml` y ajusta
esas variables.

### Panel frontend de elastic-query-service

```bash
cd elastic-query-service/frontend
npm install
npm run build      # compila TypeScript
npm run serve      # sirve en http://localhost:5501
```

---

## 8. Pruebas

### Tests unitarios

```bash
mvn clean package          # compila y ejecuta los tests unitarios de todos los módulos
```

Los tests de integración (`**/*IT.java`, Failsafe) requieren el stack vivo y se ejecutan
por separado — ver `.github/workflows/integration-test.yml`. Estrategia detallada en
[TESTING-STRATEGY-ADDENDUM.md](TESTING-STRATEGY-ADDENDUM.md).

### Pruebas de carga (JMeter)

```bash
cd jmeter
# Smoke sin autenticación sobre /actuator/health de cada servicio
jmeter -n -t health-check-load-test.jmx -l results.jtl -Jhost=localhost

# Flujo autenticado completo a través del gateway
jmeter -n -t gateway-query-flow-load-test.jmx -l results.jtl \
  -Jhost=localhost \
  -Jkeycloak_client_id=<client-id> \
  -Jkeycloak_client_secret=<client-secret> \
  -Jkeycloak_username=<usuario> \
  -Jkeycloak_password=<password> \
  -Jquery_word=hello
```

Detalles en [jmeter/README.md](jmeter/README.md).

### Postman

Importa [twitter-analytics.postman_collection.json](twitter-analytics.postman_collection.json):
cubre la obtención del token en Keycloak, las 3 APIs JSON enrutadas por el gateway
(`elastic-query-service`, `analytics-service`, `kafka-streams-service`) y sus 3 endpoints
de fallback.

---

## 10. Documentación adicional

- [SERVICES.md](SERVICES.md) — descripción detallada de cada servicio y librería.
- [PORTFOLIO.md](PORTFOLIO.md) — resumen de las decisiones de arquitectura destacadas.
- [REVIEW_NOTES.md](REVIEW_NOTES.md) — notas de revisión técnica: bugs corregidos, hallazgos pendientes y áreas no revisadas.
- [TESTING-STRATEGY-ADDENDUM.md](TESTING-STRATEGY-ADDENDUM.md) — estrategia de pruebas.
- [jmeter/README.md](jmeter/README.md) — planes de carga.
# Twitter-Microservicios
