export const API_BASE = "";

export async function fetchWithAuth(url: string, options: RequestInit = {}) {
  const mergedOptions = {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    credentials: "include" as RequestCredentials,
  };

  const response = await fetch(`${API_BASE}${url}`, mergedOptions);

  if (!response.ok) {
    if (response.status === 401 || response.status === 403) {
      if (url !== "/auth/me") {
        window.location.href = "/login";
      }
    }
    throw new Error(`API Error: ${response.statusText}`);
  }

  return response;
}

export async function getJson(url: string) {
  const res = await fetchWithAuth(url);
  return res.json();
}

export async function postJson(url: string, body: any) {
  const res = await fetchWithAuth(url, {
    method: "POST",
    body: JSON.stringify(body),
  });
  return res.json();
}

export async function patchJson(url: string, body: any) {
  const res = await fetchWithAuth(url, {
    method: "PATCH",
    body: JSON.stringify(body),
  });
  return res.json();
}

export async function deleteJson(url: string) {
  const res = await fetchWithAuth(url, {
    method: "DELETE",
  });
  return res.json();
}
