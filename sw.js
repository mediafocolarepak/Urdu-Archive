// Minimal service worker: makes the app installable and speeds up repeat loads.
// Cache name is keyed to the same ?v= deploy version already used across the app's own
// script/style tags (see index.html), so a new deploy gets a fresh cache automatically -
// old caches are dropped in 'activate' below.
const CACHE_VERSION = '20260918182542';
const CACHE_NAME = 'urdu-archive-' + CACHE_VERSION;

// Only same-origin static assets are ever cached. Supabase (API/Auth/Storage) and Google
// Drive requests are cross-origin and inherently dynamic (signed URLs, live data) - the
// fetch handler below leaves those completely untouched (network only, no interception).
const PRECACHE_URLS = [
  './',
  './index.html',
  './css/style.css',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-512.png',
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(PRECACHE_URLS)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(names => Promise.all(names.filter(n => n !== CACHE_NAME).map(n => caches.delete(n))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  if (url.origin !== self.location.origin || event.request.method !== 'GET') return; // network only

  // Path checks are substring/suffix-based, not startsWith('/js/') or === '/index.html', because
  // this app is served from a GitHub Pages *project* site (https://.../Urdu-Archive/...), not a
  // domain root - the real pathname is "/Urdu-Archive/js/app.js" etc, which never matched those
  // exact-prefix checks. That silently made every request - including this file's own app.js/
  // index.html - fall into the cache-first branch below instead of network-first, so nobody ever
  // saw a new deploy without manually clearing site data (found 2026-09-18, chasing why several
  // same-session deploys weren't showing up in a browser that had used the app before).
  const isVersionedScript = url.pathname.includes('/js/') || url.pathname.endsWith('.html') || url.pathname.endsWith('/');
  if (isVersionedScript) {
    // network-first: these carry a ?v= cache-buster already, but network-first also means
    // a user is never stuck on stale app code just because the SW cache wasn't evicted yet.
    // { cache: 'no-store' } is required here, not optional - without it, fetch() still obeys
    // whatever Cache-Control header GitHub Pages sent (commonly ~10 min), so a "network" fetch
    // can silently return a stale response from the browser's own HTTP cache, defeating the
    // whole point of network-first (this was the actual cause of "changes don't show up").
    event.respondWith(
      fetch(event.request, { cache: 'no-store' })
        .then(res => { caches.open(CACHE_NAME).then(cache => cache.put(event.request, res.clone())); return res; })
        .catch(() => caches.match(event.request))
    );
  } else {
    // cache-first for css/icons - rarely change, and are still version-busted when they do
    event.respondWith(
      caches.match(event.request).then(cached => cached || fetch(event.request).then(res => {
        caches.open(CACHE_NAME).then(cache => cache.put(event.request, res.clone()));
        return res;
      }))
    );
  }
});
