import type { AppError } from "./types.ts";

export function validatePetAge(birthDate: string): {
  valid: boolean;
  ageMonths: number;
  error?: string;
} {
  const birth = new Date(birthDate);
  const now = new Date();
  const ageMonths =
    (now.getFullYear() - birth.getFullYear()) * 12 +
    (now.getMonth() - birth.getMonth());

  if (ageMonths < 4) {
    return {
      valid: false,
      ageMonths,
      error: "Pet deve ter pelo menos 4 meses (120 dias)",
    };
  }
  return { valid: true, ageMonths };
}

export function validateUserAge(birthDate: string): {
  valid: boolean;
  age: number;
  error?: string;
} {
  const birth = new Date(birthDate);
  const now = new Date();
  let age = now.getFullYear() - birth.getFullYear();
  const m = now.getMonth() - birth.getMonth();
  if (m < 0 || (m === 0 && now.getDate() < birth.getDate())) age--;

  if (age < 18) {
    return { valid: false, age, error: "Tutor deve ter pelo menos 18 anos" };
  }
  return { valid: true, age };
}

export function validateGeoPoint(
  lat: number,
  lng: number
): { valid: boolean; error?: string } {
  if (lat < -90 || lat > 90)
    return { valid: false, error: "Latitude invalida" };
  if (lng < -180 || lng > 180)
    return { valid: false, error: "Longitude invalida" };
  return { valid: true };
}

export function createError(
  message: string,
  code: string,
  status: number
): AppError {
  return { message, code, status };
}
