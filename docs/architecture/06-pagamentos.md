# 06 - Pagamentos e Monetizacao

## Visao Geral

O PetMatch usa **Stripe** para gerenciar assinaturas e pagamentos. Integracao com API do **Melhor Envio** para emissao de notas fiscais.

---

## 1. Planos

| Feature | Free | Premium |
|---------|------|---------|
| Pets cadastrados | 2 | Ilimitado |
| Likes por dia | 20 | Ilimitado |
| Super likes por dia | 1 | 10 |
| Raio de busca | 30km | 100km |
| Filtros avancados | Nao | Sim |
| Ver quem curtiu | Nao | Sim |
| Remover anuncios | Nao | Sim |
| Preco | Grátis | R$ 29,90/mes ou R$ 249,90/ano |

---

## 2. Arquitetura de Pagamentos

```
┌──────────┐     ┌──────────────┐     ┌──────────────┐
│ Flutter  │────>│ Stripe SDK   │────>│ Stripe API   │
│ App      │     │ (Frontend)   │     │ (Servidor)   │
└──────────┘     └──────────────┘     └──────┬───────┘
                                             │
                                        Webhooks
                                             │
┌──────────┐     ┌──────────────┐     ┌──────▼───────┐
│ Supabase │<────│ Edge Function│<────│ Stripe       │
│ DB       │     │ (webhook)    │     │ Webhook      │
└──────────┘     └──────────────┘     └──────────────┘
```

---

## 3. Fluxos de Pagamento

### 3.1 Assinatura Premium

```
1. Usuario clica "Assinar Premium"
2. App abre Stripe Checkout (Client Secret)
3. Usuario insere dados de cartao
4. Stripe processa pagamento
5. Stripe envia webhook para Edge Function
6. Edge Function atualiza users.subscription no Supabase
7. Edge Function envia notificacao push de confirmacao
8. App atualiza estado do usuario (acesso premium)
```

### 3.2 Renovacao Automatica

```
1. Stripe cobra automaticamente na data de renovacao
2. Stripe envia webhook: invoice.paid
3. Edge Function renova subscription no Supabase
4. Se pagamento falhar: webhook: invoice.payment_failed
5. Edge Function marca subscription como past_due
6. Envia notificacao: "Pagamento nao processado"
7. Retry 3x ao longo de 7 dias
8. Se falhar tudo: subscription cancelada
```

### 3.3 Cancelamento

```
1. Usuario clica "Cancelar assinatura"
2. App chama Stripe API para cancelar
3. Acesso continua ate o final do periodo pago
4. Na data de expiracao: subscription vira expired
5. Usuario volta para plano Free
```

### 3.4 Reembolso

```
1. Usuario solicita reembolso (suporte)
2. Admin processa via Dashboard Stripe
3. Stripe devolve valor em ate 5-10 dias uteis
4. Subscription cancelada imediatamente
5. Registro no audit_log
```

---

## 4. Inteccao Stripe

### 4.1 Setup

```typescript
// supabase/functions/_shared/stripe.ts
import Stripe from "https://esm.sh/stripe@14";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-06-20",
});

export { stripe };
```

### 4.2 Criar Checkout Session

```typescript
// supabase/functions/create-checkout-session/index.ts
import { stripe } from "../_shared/stripe.ts";
import { authenticateRequest } from "../_shared/authMiddleware.ts";
import { handleCors, corsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  const auth = await authenticateRequest(req);
  if (!auth) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const { plan } = await req.json(); // "monthly" ou "yearly"

  const priceId = plan === "yearly"
    ? Deno.env.get("STRIPE_PRICE_YEARLY")!
    : Deno.env.get("STRIPE_PRICE_MONTHLY")!;

  const session = await stripe.checkout.sessions.create({
    customer_email: auth.user.email,
    mode: "subscription",
    payment_method_types: ["card"],
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${Deno.env.get("APP_URL")}/payment/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${Deno.env.get("APP_URL")}/payment/cancel`,
    metadata: { user_id: auth.user.uid, plan },
    subscription_data: { trial_period_days: 7 },
  });

  return new Response(JSON.stringify({ sessionId: session.id, url: session.url }), {
    status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
```

### 4.3 Webhook Handler

```typescript
// supabase/functions/stripe-webhook/index.ts
import { stripe } from "../_shared/stripe.ts";
import { getSupabaseClient } from "../_shared/supabaseClient.ts";
import { sendPushNotification } from "../_shared/notifications.ts";

Deno.serve(async (req) => {
  const body = await req.text();
  const sig = req.headers.get("stripe-signature")!;
  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;

  let event;
  try {
    event = stripe.webhooks.constructEvent(body, sig, webhookSecret);
  } catch (err) {
    return new Response(`Webhook Error: ${err.message}`, { status: 400 });
  }

  const supabase = getSupabaseClient();

  switch (event.type) {
    case "checkout.session.completed": {
      const session = event.data.object;
      const userId = session.metadata.user_id;
      const plan = session.metadata.plan;
      const now = new Date();
      const expiresAt = new Date(now);
      expiresAt.setMonth(expiresAt.getMonth() + (plan === "yearly" ? 12 : 1));

      await supabase.from("subscriptions").insert({
        user_id: userId,
        plan,
        status: "active",
        amount: plan === "yearly" ? 24990 : 2990,
        currency: "BRL",
        payment_method: "stripe",
        payment_id: session.subscription,
        starts_at: now.toISOString(),
        expires_at: expiresAt.toISOString(),
      });

      await supabase.from("users").update({
        subscription: {
          plan: `premium_${plan}`,
          status: "active",
          expires_at: expiresAt.toISOString(),
        },
      }).eq("uid", userId);

      await sendPushNotification({
        token: (await supabase.from("users").select("fcm_token").eq("uid", userId).single()).data?.fcm_token,
        title: "Premium Ativado!",
        body: "Aproveite todos os beneficios do PetMatch Premium!",
        data: { type: "subscription", screen: "profile" },
      });
      break;
    }

    case "invoice.paid": {
      const invoice = event.data.object;
      const subscriptionId = invoice.subscription;
      await supabase.from("subscriptions").update({
        status: "active",
        expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
      }).eq("payment_id", subscriptionId);
      break;
    }

    case "invoice.payment_failed": {
      const invoice = event.data.object;
      const subscriptionId = invoice.subscription;
      const { data: sub } = await supabase.from("subscriptions").select("user_id").eq("payment_id", subscriptionId).single();
      if (sub) {
        await supabase.from("subscriptions").update({ status: "past_due" }).eq("payment_id", subscriptionId);
        await sendPushNotification({
          token: (await supabase.from("users").select("fcm_token").eq("uid", sub.user_id).single()).data?.fcm_token,
          title: "Pagamento nao processado",
          body: "Atualize seu metodo de pagamento para manter o Premium.",
          data: { type: "payment_failed", screen: "payment" },
        });
      }
      break;
    }

    case "customer.subscription.deleted": {
      const subscription = event.data.object;
      await supabase.from("subscriptions").update({
        status: "cancelled",
        cancelled_at: new Date().toISOString(),
      }).eq("payment_id", subscription.id);

      const { data: sub } = await supabase.from("subscriptions").select("user_id").eq("payment_id", subscription.id).single();
      if (sub) {
        await supabase.from("users").update({
          subscription: { plan: "free", status: "inactive" },
        }).eq("uid", sub.user_id);
      }
      break;
    }
  }

  return new Response("ok", { status: 200 });
});
```

---

## 5. Notas Fiscais

### 5.1 Integracao

- Servico: **NFe.io** ou **Tiny ERP**
- Emissao automatica apos cada pagamento
- Nota fiscal de servico (NFS-e) para assinatura digital

### 5.2 Fluxo

```
1. Pagamento confirmado (webhook checkout.session.completed)
2. Edge Function envia dados para API NFe.io
3. NFe.io emite NFS-e
4. PDF gerado e armazenado no Supabase Storage
5. Link enviado por email ao usuario
6. Registro no audit_log
```

### 5.3 Dados da NFS-e

| Campo | Valor |
|-------|-------|
| Descricao | "Assinatura PetMatch Premium - [plano]" |
| CNAE | 6311-9/00 (Portais, provedores de conteudo) |
| CST | Isento (Servico digital) |
| Natureza da Operacao | Servico de informatica |

---

## 6. Seguranca

| Medida | Descricao |
|--------|-----------|
| Stripe PCI | Cartao nunca toca nosso servidor |
| Webhook signature | Verificacao HMAC SHA-256 |
| Idempotency keys | Prevencao de cobranca duplicada |
| Webhook retries | Stripe retries automaticos (3x) |
| Logging | Todas as transacoes registradas em audit_logs |

---

## 7. Variaveis de Ambiente

```env
STRIPE_SECRET_KEY=sk_live_xxx
STRIPE_PUBLISHABLE_KEY=pk_live_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
STRIPE_PRICE_MONTHLY=price_monthly_xxx
STRIPE_PRICE_YEARLY=price_yearly_xxx
NFE_API_KEY=xxx
NFE_API_SECRET=xxx
```

---

## 8. Metricas

| Metrica | Meta |
|---------|------|
| Taxa de conversao Free→Premium | > 5% |
| Churn mensal | < 8% |
| Ticket medio | R$ 29,90 |
| LTV estimado | R$ 180 |
| Tempo medio para conversao | < 14 dias |
