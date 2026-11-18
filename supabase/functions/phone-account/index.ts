// Edge Function "phone-account" (Owner's request, 2026-11-18): signing up with a mobile number instead of an email.
// Many members, the elderly above all, have no email or cannot confirm one. The number becomes the login: behind the
// scenes the account gets an internal address "<digits>@phone.dua.invalid" (".invalid" is reserved: no mail is ever
// delivered there) and is created already confirmed, so no email and no SMS are needed.
//
//   { action: "signup", phone, password, full_name, city, membership_type, gender, date_of_birth }
//       Anyone (the app calls it with the public key). One account per number: refused if the number already belongs
//       to an account, as login or as the phone of a profile. The profile is filled by the usual trigger
//       (handle_new_user, 85; date of birth, 120) from the same fields the email sign-up sends.
//   { action: "set_password", user_id, password }
//       Admins only (checked from the caller's own sign-in): a temporary password for someone who forgot theirs.
//
// Deploy: Supabase Dashboard -> Edge Functions -> Deploy a new function -> Via Editor, name "phone-account", paste this
// file, Deploy. Keep "Verify JWT" on (the app sends its public key or the signed-in user's token). The service key is
// provided to the function by Supabase itself; it never appears in the app.

import { createClient } from 'npm:@supabase/supabase-js@2';

const DOMAIN = 'phone.dua.invalid';
const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// Digits only, Pakistan by default: 0300 1234567 -> 923001234567; +92 300 1234567 and 0092... the same.
function normalizePhone(raw: unknown): string | null {
  let d = String(raw ?? '').replace(/\D/g, '');
  if (d.startsWith('00')) d = d.slice(2);
  else if (d.startsWith('0')) d = '92' + d.slice(1);
  if (d.startsWith('92') && d.length !== 12) return null;
  return d.length >= 10 && d.length <= 15 ? d : null;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  const reply = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), { status, headers: { ...CORS, 'Content-Type': 'application/json' } });
  const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  let b: Record<string, unknown>;
  try { b = await req.json(); } catch { return reply({ error: 'bad_request' }, 400); }

  if (b.action === 'signup') {
    const digits = normalizePhone(b.phone);
    const password = String(b.password ?? '');
    const full_name = String(b.full_name ?? '').trim();
    const city = String(b.city ?? '').trim();
    const membership_type = String(b.membership_type ?? '').trim();
    const gender = String(b.gender ?? '');
    const date_of_birth = String(b.date_of_birth ?? '');
    if (!digits) return reply({ error: 'phone_invalid' }, 400);
    if (password.length < 6) return reply({ error: 'password_short' }, 400);
    if (!full_name || !city || !membership_type || !['M', 'F'].includes(gender) || !/^\d{4}-\d{2}-\d{2}$/.test(date_of_birth)) {
      return reply({ error: 'fields_missing' }, 400);
    }
    // A number already given in a profile (an account made with an email) counts as taken too.
    const { data: profiles, error: pErr } = await admin.from('user_profiles').select('phone').not('phone', 'is', null);
    if (pErr) return reply({ error: 'server', detail: pErr.message }, 500);
    if ((profiles ?? []).some((p: { phone: string }) => normalizePhone(p.phone) === digits)) return reply({ error: 'phone_in_use' }, 409);

    const { error } = await admin.auth.admin.createUser({
      email: `${digits}@${DOMAIN}`,
      password,
      email_confirm: true,
      user_metadata: { full_name, city, membership_type, phone: '+' + digits, gender, date_of_birth, login: 'phone' },
    });
    if (error) {
      if (/already|registered|exists/i.test(error.message)) return reply({ error: 'phone_in_use' }, 409);
      return reply({ error: 'server', detail: error.message }, 500);
    }
    return reply({ ok: true, login: `${digits}@${DOMAIN}` });
  }

  if (b.action === 'set_password') {
    const token = (req.headers.get('Authorization') ?? '').replace(/^Bearer\s+/i, '');
    const { data: caller } = await admin.auth.getUser(token);
    if (!caller?.user) return reply({ error: 'not_signed_in' }, 401);
    const { data: roles } = await admin.from('user_roles').select('role').eq('user_id', caller.user.id);
    if (!(roles ?? []).some((r: { role: string }) => r.role === 'admin')) return reply({ error: 'admins_only' }, 403);
    const userId = String(b.user_id ?? '');
    const password = String(b.password ?? '');
    if (!userId || password.length < 6) return reply({ error: 'password_short' }, 400);
    const { error } = await admin.auth.admin.updateUserById(userId, { password });
    if (error) return reply({ error: 'server', detail: error.message }, 500);
    return reply({ ok: true });
  }

  return reply({ error: 'unknown_action' }, 400);
});
