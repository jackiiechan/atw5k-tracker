// ATW 5K Workshop — Service Worker
// Cache-first for all app assets so the lap tracker works fully offline on iPad.

const CACHE = 'atw5k-v1';

const PRECACHE = [
  './',
  './hub.html',
  './lap_tracker.html',
  './index.html',
  // audio briefing files
  './audio/pace_01.mp3',
  './audio/pace_02.mp3',
  './audio/pace_03.mp3',
  './audio/pace_04.mp3',
  './audio/pace_05.mp3',
  './audio/pace_06.mp3',
];

// ── Install: pre-cache everything we know about ─────────────
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE).then(cache => cache.addAll(PRECACHE))
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

// ── Fetch: cache-first, fall back to network ─────────────────
self.addEventListener('fetch', event => {
  // Only handle same-origin GET requests
  if (event.request.method !== 'GET') return;

  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) return cached;

      return fetch(event.request).then(response => {
        // Cache successful responses for future offline use
        if (response && response.status === 200) {
          const clone = response.clone();
          caches.open(CACHE).then(cache => cache.put(event.request, clone));
        }
        return response;
      }).catch(() => {
        // Network unavailable and nothing in cache — return nothing
        // (browser will show its own offline error for uncached navigations)
      });
    })
  );
});
