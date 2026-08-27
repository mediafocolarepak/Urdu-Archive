// Minimal service worker: makes the app installable and speeds up repeat loads.
// Cache name is keyed to the same ?v= deploy version already used across the app's own
// script/style tags (see index.html), so a new deploy gets a fresh cache automatically -
// old caches are dropped in 'activate' below.
const CACHE_VERSION = '20260827160000';
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

  const isVersionedScript = url.pathname.startsWith('/js/') || url.pathname === '/index.html' || url.pathname === '/';
  if (isVersionedScript) {
    // network-first: these carry a ?v= cache-buster already, but network-first also means
    // a user is never stuck on stale app code just because the SW cache wasn't evicted yet
    event.respondWith(
      fetch(event.request)
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
