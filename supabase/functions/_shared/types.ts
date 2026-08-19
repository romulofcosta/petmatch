export interface User {
  uid: string;
  email: string;
  display_name: string;
  photo_url?: string;
  phone?: string;
  birth_date: string;
  location: { type: "Point"; coordinates: [number, number] };
  geohash: string;
  city: string;
  state: string;
  country: string;
  preferences: UserPreferences;
  subscription: UserSubscription;
  stats: UserStats;
  is_active: boolean;
  is_verified: boolean;
  is_banned: boolean;
  created_at: string;
  updated_at: string;
}

export interface UserPreferences {
  notifications: { push: boolean; email: boolean };
  distance_radius: number;
  interest_filter: string[];
}

export interface UserSubscription {
  plan: "free" | "premium_monthly" | "premium_yearly";
  status: "active" | "cancelled" | "expired";
  expires_at?: string;
}

export interface UserStats {
  total_matches: number;
  total_messages: number;
  profile_views: number;
}

export interface Pet {
  id: string;
  owner_id: string;
  name: string;
  type: "dog" | "cat";
  sex: "male" | "female";
  breed: string;
  breed_group: string;
  birth_date: string;
  age_months: number;
  weight_kg?: number;
  description?: string;
  personality_tags: string[];
  interests: ("socialization" | "breeding" | "adoption")[];
  main_photo_url: string;
  photos: string[];
  location: { type: "Point"; coordinates: [number, number] };
  geohash: string;
  is_active: boolean;
  is_banned: boolean;
  created_at: string;
}

export interface Swipe {
  id: string;
  swiper_id: string;
  swiped_pet_id: string;
  swiped_owner_id: string;
  action: "like" | "superlike" | "pass";
  created_at: string;
}

export interface Match {
  id: string;
  user1_id: string;
  user1_pet_id: string;
  user2_id: string;
  user2_pet_id: string;
  matched_via: "like" | "superlike";
  status: "active" | "unmatched" | "blocked";
  created_at: string;
}

export interface Message {
  id: string;
  conversation_id: string;
  sender_id: string;
  type: "text" | "photo" | "location" | "audio" | "video";
  content: string;
  metadata?: Record<string, unknown>;
  is_read: boolean;
  created_at: string;
}

export interface Conversation {
  id: string;
  match_id: string;
  participants: string[];
  status: "active" | "archived";
  last_message?: {
    text: string;
    sender_id: string;
    timestamp: string;
  };
  unread_count_user1: number;
  unread_count_user2: number;
  created_at: string;
}

export interface Report {
  id: string;
  reporter_id: string;
  type: "user" | "pet" | "message";
  target_id: string;
  category: string;
  description?: string;
  evidence_urls: string[];
  status: "pending" | "reviewed" | "resolved" | "dismissed";
  created_at: string;
}

export type AppError = {
  message: string;
  code: string;
  status: number;
};
