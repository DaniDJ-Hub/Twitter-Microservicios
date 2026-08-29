// No API Gateway assumed here: the panel talks to elastic-query-service's own port directly.
// The bearer token is deliberately NOT persisted anywhere (not localStorage, not sessionStorage) -
// it's a live Keycloak JWT, so it only lives in memory for the current page load.

const STORAGE_KEY = "elastic-query-panel:baseUrl";
const DEFAULT_BASE_URL = "http://localhost:8183";

let bearerToken = "";

export function loadBaseUrl(): string {
  return localStorage.getItem(STORAGE_KEY) || DEFAULT_BASE_URL;
}

export function saveBaseUrl(baseUrl: string): void {
  localStorage.setItem(STORAGE_KEY, baseUrl);
}

export function setBearerToken(token: string): void {
  bearerToken = token.trim();
}

export function getBearerToken(): string {
  return bearerToken;
}
