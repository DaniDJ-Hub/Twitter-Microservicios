import { loadBaseUrl, saveBaseUrl, setBearerToken } from "./config.js";
import { getAllDocuments, getDocumentById, getDocumentByIdV2, onApiCall, type ApiCallLog } from "./api.js";
import { qs, renderResult } from "./dom.js";

function setupSettingsForm(): void {
  const baseUrlInput = qs<HTMLInputElement>("#baseUrl");
  const tokenInput = qs<HTMLTextAreaElement>("#bearerToken");
  const saveBtn = qs<HTMLButtonElement>("#saveConfigBtn");
  const savedMsg = qs<HTMLElement>("#configSavedMsg");

  baseUrlInput.value = loadBaseUrl();

  tokenInput.addEventListener("input", () => setBearerToken(tokenInput.value));

  saveBtn.addEventListener("click", () => {
    saveBaseUrl(baseUrlInput.value.trim());
    setBearerToken(tokenInput.value);
    savedMsg.textContent = "Configuracion aplicada.";
    setTimeout(() => (savedMsg.textContent = ""), 2000);
  });
}

function setupInspector(): void {
  const requestPre = qs<HTMLElement>("#lastRequest");
  const responsePre = qs<HTMLElement>("#lastResponse");

  onApiCall((log: ApiCallLog) => {
    const headers = { ...log.requestHeaders };
    if (headers.Authorization) headers.Authorization = "Bearer <oculto>";
    requestPre.textContent = JSON.stringify({ method: log.method, url: log.url, headers }, null, 2);
    responsePre.textContent = JSON.stringify({ status: log.responseStatus, body: log.responseBody }, null, 2);
  });
}

function setupGetAllDocumentsForm(): void {
  const form = qs<HTMLFormElement>("#getAllDocumentsForm");
  const result = qs<HTMLElement>('[data-result="getAllDocuments"]');

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    try {
      const documents = await getAllDocuments();
      renderResult(result, "success", `${documents.length} documento(s).`, documents);
    } catch (error) {
      renderResult(result, "error", error instanceof Error ? error.message : "Error desconocido.");
    }
  });
}

function setupGetDocumentByIdForm(): void {
  const form = qs<HTMLFormElement>("#getDocumentByIdForm");
  const result = qs<HTMLElement>('[data-result="getDocumentById"]');

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    const data = new FormData(form);
    const id = String(data.get("id"));
    const version = data.get("version");

    try {
      const document = version === "v2" ? await getDocumentByIdV2(id) : await getDocumentById(id);
      renderResult(result, "success", `Documento ${id} (${version === "v2" ? "v2" : "v1"}).`, document);
    } catch (error) {
      renderResult(result, "error", error instanceof Error ? error.message : "Error desconocido.");
    }
  });
}

setupSettingsForm();
setupInspector();
setupGetAllDocumentsForm();
setupGetDocumentByIdForm();
