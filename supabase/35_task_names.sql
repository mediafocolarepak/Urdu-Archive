-- Mostrare il nome (non l'email) di chi ha preso/creato un task nella bacheca Tasks richiede
-- che un Coordinator possa leggere il full_name di un altro utente da user_profiles - finora
-- quella lettura era permessa solo all'Admin (16_signup_chat_splash.sql), il Coordinator vedeva
-- solo il proprio profilo. Allarga la policy allo stesso livello già usato per le candidature
-- "Join the Team" (current_role_is('coordinator') = coordinator o admin).

drop policy if exists "user_profiles_select_admin" on public.user_profiles;
drop policy if exists "user_profiles_select_reviewers" on public.user_profiles;
create policy "user_profiles_select_reviewers" on public.user_profiles
  for select using (current_role_is('coordinator'));

select 'user_profiles: lettura profili altrui estesa a Coordinator+Admin.' as result;
