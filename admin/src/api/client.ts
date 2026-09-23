// Serviqo Admin — API Client
import type { ApiResponse, AuthResponse, User, ApiError } from '../types';

const TOKEN_KEY = 'serviqo_admin_token';
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://127.0.0.1:8080/api';

export const tokenStorage = {
  get: (): string | null => localStorage.getItem(TOKEN_KEY),
  set: (token: string): void => localStorage.setItem(TOKEN_KEY, token),
  clear: (): void => localStorage.removeItem(TOKEN_KEY),
};

async function request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
  const cleanEndpoint = endpoint.startsWith('/') ? endpoint : `/${endpoint}`;
  const url = `${API_BASE_URL}${cleanEndpoint}`;
  const token = tokenStorage.get();

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    ...((options.headers as Record<string, string>) || {}),
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  try {
    const res = await fetch(url, {
      ...options,
      headers,
    });

    const data = await res.json().catch(() => null);

    if (!res.ok) {
      const err: ApiError = {
        message: data?.message || `HTTP error ${res.status}: ${res.statusText}`,
        errors: data?.errors,
        status: res.status,
      };
      throw err;
    }

    return data as T;
  } catch (error: any) {
    if (error.status) throw error;
    throw {
      message: error.message || 'Network connection failed. Ensure the Serviqo backend is running.',
    } as ApiError;
  }
}

export const authApi = {
  async login(login: string, password: string): Promise<{ user: User; token: string }> {
    const res = await request<AuthResponse>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({
        login,
        password,
        expected_role: 'admin',
      }),
    });

    if (!res.success || !res.data) {
      throw { message: res.message || 'Authentication failed' } as ApiError;
    }

    if (res.data.user.role !== 'admin') {
      throw { message: 'Access denied: Administrator privileges required.' } as ApiError;
    }

    tokenStorage.set(res.data.token);
    return res.data;
  },

  async me(): Promise<User> {
    const res = await request<ApiResponse<{ user: User }>>('/auth/me', {
      method: 'GET',
    });

    if (!res.success || !res.data?.user) {
      throw { message: 'Unable to retrieve administrator profile' } as ApiError;
    }

    if (res.data.user.role !== 'admin') {
      tokenStorage.clear();
      throw { message: 'Access denied: Administrator privileges required.' } as ApiError;
    }

    return res.data.user;
  },

  async logout(): Promise<void> {
    try {
      await request<ApiResponse>('/auth/logout', {
        method: 'POST',
      });
    } finally {
      tokenStorage.clear();
    }
  },
};
