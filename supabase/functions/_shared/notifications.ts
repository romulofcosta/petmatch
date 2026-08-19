import { getSupabaseClient } from "./supabaseClient.ts";

const fcmServerKey = Deno.env.get("FCM_SERVER_KEY")!;

export async function sendPushNotification(payload: {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
  imageUrl?: string;
}): Promise<boolean> {
  if (!fcmServerKey) return false;

  try {
    const message = {
      to: payload.token,
      notification: {
        title: payload.title,
        body: payload.body,
        ...(payload.imageUrl && { image: payload.imageUrl }),
      },
      data: payload.data || {},
      priority: "high",
    };

    const res = await fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: {
        Authorization: `key=${fcmServerKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(message),
    });

    return res.ok;
  } catch {
    return false;
  }
}

export async function notifyNewMatch(
  userId: string,
  matchedUserName: string,
  matchedPetName: string,
  matchedPetPhoto: string
): Promise<void> {
  const supabase = getSupabaseClient();

  const { data } = await supabase
    .from("users")
    .select("fcm_token")
    .eq("uid", userId)
    .single();

  if (data?.fcm_token) {
    await sendPushNotification({
      token: data.fcm_token,
      title: "Novo Match!",
      body: `Voce e ${matchedPetName} deram match!`,
      imageUrl: matchedPetPhoto,
      data: { type: "match", screen: "matches" },
    });
  }

  await supabase.from("notifications").insert({
    user_id: userId,
    type: "match",
    title: "Novo Match!",
    body: `Voce e ${matchedPetName} deram match!`,
    data: { screen: "matches" },
  });
}
