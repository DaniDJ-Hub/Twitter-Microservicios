import { loadBaseUrl, getBearerToken } from "./config.js";
import type { ElasticQueryServiceResponseModel, ElasticQueryServiceResponseModelV2, ErrorDTO } from "./types.js";

export interface ApiCallLog {
  method: string;
  url: string;
  requestHeaders: Record<string, string>;
  responseStatus: number | null;
  responseBody: unknown;
}

export type ApiLogListener = (log: ApiCallLog) => void;

let logListener: ApiLogListener | null = null;

export function onApiCall(listener: ApiLogListener): void {
  logListener = listener;
}

function stripTrailingSlash(url: string): string {
  return url.endsWith("/") ? url.slice(0, -1) : url;
}

async function request<T>(path: string, accept: string): Promise<T> {
  const url = `${stripTrailingSlash(loadBaseUrl())}${path}`;
  const token = getBearerToken();
  const headers: Record<string, string> = { Accept: accept };
  if (token) headers.Authorization = `Bearer ${token}`;

  let response: Response;
  try {
    response = await fetch(url, { method: "GET", headers });
  } catch (error) {
    logListener?.({
      method: "GET",
      url,
      requestHeaders: headers,
      responseStatus: null,
      responseBody: { networkError: error instanceof Error ? error.message : String(error) },
    });
    throw error;
  }

  const text = await response.text();
  let parsedBody: unknown = null;
  if (text) {
    try {
      parsedBody = JSON.parse(text);
    } catch {
      parsedBody = text;
    }
  }

  logListener?.({
    method: "GET",
    url,
    requestHeaders: headers,
    responseStatus: response.status,
    responseBody: parsedBody,
  });

  if (!response.ok) {
    const errorDto = parsedBody as Partial<ErrorDTO> | null;
    throw new Error(errorDto?.message ?? `HTTP ${response.status} calling ${url}`);
  }

  return parsedBody as T;
}

export function getAllDocuments(): Promise<ElasticQueryServiceResponseModel[]> {
  return request<ElasticQueryServiceResponseModel[]>("/documents", "application/vnd.api.v1+json");
}

export function getDocumentById(id: string): Promise<ElasticQueryServiceResponseModel> {
  return request<ElasticQueryServiceResponseModel>(`/documents/${encodeURIComponent(id)}`, "application/vnd.api.v1+json");
}

export function getDocumentByIdV2(id: string): Promise<ElasticQueryServiceResponseModelV2> {
  return request<ElasticQueryServiceResponseModelV2>(`/documents/${encodeURIComponent(id)}`, "application/vnd.api.v2+json");
}
