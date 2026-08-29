# JMeter load tests

Two test plans, both validated against JMeter 5.6.3 (`jmeter -n -t <plan> ...`).

## health-check-load-test.jmx
Unauthenticated smoke/load test against every service's `/actuator/health`.
No credentials needed - just the stack up (`docker-compose` or local run).

```
jmeter -n -t health-check-load-test.jmx -l results.jtl -Jhost=localhost
```

## gateway-query-flow-load-test.jmx
Realistic authenticated flow: gets a Keycloak access token, then drives
elastic-query-service / analytics-service / kafka-streams-service through
gateway-service. Requires a Keycloak realm/client already configured
(realm `microservices-realm` by default).

```
jmeter -n -t gateway-query-flow-load-test.jmx -l results.jtl \
  -Jhost=localhost \
  -Jkeycloak_client_id=<your-client-id> \
  -Jkeycloak_client_secret=<your-client-secret> \
  -Jkeycloak_username=<test-user> \
  -Jkeycloak_password=<test-password> \
  -Jquery_word=hello
```

Both plans default to `-Jhost=localhost` and the ports from the current
config-server-repository port map (gateway 9092, Keycloak 9091). Override
with `-J<prop>` as needed for other environments.
