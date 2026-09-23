// Serviqo Admin — TypeScript Type Definitions
export type UserRole = 'customer' | 'technician' | 'admin';
export type UserStatus = 'active' | 'inactive' | 'suspended';

export interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: UserRole;
  status: UserStatus;
  email_verified_at: string | null;
  phone_verified_at: string | null;
  avatar_url?: string | null;
  created_at: string;
  updated_at: string;
  customer?: CustomerProfile | null;
  technician?: TechnicianProfile | null;
}

export interface CustomerProfile {
  id: string;
  user_id: string;
  city_id?: string | null;
  default_address?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  total_requests: number;
}

export interface TechnicianProfile {
  id: string;
  user_id: string;
  city_id?: string | null;
  experience_years: number;
  bio?: string | null;
  visiting_charge: string | number;
  verification_status: 'pending' | 'under_review' | 'verified' | 'rejected' | 'suspended';
  is_available: boolean;
  rating_avg: string | number;
  rating_count: number;
  total_completed_services: number;
}

export interface AuthResponse {
  success: boolean;
  message: string;
  data: {
    user: User;
    token: string;
  };
}

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  errors?: Record<string, string[]>;
}

export interface ApiError {
  message: string;
  errors?: Record<string, string[]>;
  status?: number;
}
