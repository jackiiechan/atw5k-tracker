// ATW 5K Workshop — Service Worker
// Network-first for HTML, cache-first for audio/assets.

const CACHE = 'atw5k-v5';

const HTML_FILES = ['./', './index.html', './hub.html', './lap_tracker.html'];

const PRECACHE_ASSETS = [
  './audio/pace_01.mp3',
  './audio/pace_02.mp3',
  './audio/pace_03.mp3',
  './audio/pace_04.mp3',
  './audio/pace_05.mp3',
  './audio/pace_06.mp3',
];

// ── Install: pre-cache audio assets ─────────────────────────
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE).then(cache => cache.addAll(PRECACHE_ASSETS))
  );
  self.skipWaiting();
});

// ── Activate: wipe old caches ────────────────────────────────
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

// ── Fetch ─────────────────────────────────────────────────────
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;

  const url = new URL(event.request.url);
  const isHTML = HTML_FILES.some(f => url.pathname.endsWith(f.replace('./', '/'))) ||
                 url.pathname === '/' ||
                 url.pathname.endsWith('.html');

  if (isHTML) {
    // Network-first for HTML: always get fresh content, fall back to cache offline
    event.respondWith(
      fetch(event.request).then(response => {
        if (response && response.status === 200) {
          const clone = response.clone();
          caches.open(CACHE).then(cache => cache.put(event.request, clone));
        }
        return response;
      }).catch(() => caches.match(event.request))
    );
  } else {
    // Cache-first for assets (audio, etc.)
    event.respondWith(
      caches.match(event.request).then(cached => {
        if (cached) return cached;
        return fetch(event.request).then(response => {
          if (response && response.status === 200) {
            const clone = response.clone();
            caches.open(CACHE).then(cache => cache.put(event.request, clone));
          }
          return response;
        }).catch(() => {});
      })
    );
  }
});
