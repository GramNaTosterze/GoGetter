'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"main.dart.js": "0999957ced20ead5c275bde596a90355",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/AssetManifest.bin": "19157d2fdf917b2912e1d55630c00b32",
"assets/fonts/MaterialIcons-Regular.otf": "3a3ddee4b03b04066a71f74e5d242949",
"assets/assets/images/blockv2_1.png": "4e1e21ef208fc1e3c01482ed343fa337",
"assets/assets/images/block_7.png": "768ea2bcc44d65b3ce93d1861485a6f9",
"assets/assets/images/board.png": "3855faa5951590311460889c5243259f",
"assets/assets/images/blockv2_7.png": "768ea2bcc44d65b3ce93d1861485a6f9",
"assets/assets/images/plansza2.jpg": "cc91c15d0bb068be7323f202036dfed9",
"assets/assets/images/blockv2_8.png": "0a794690ed96f291918d7935fdc42de5",
"assets/assets/images/UI/no_connection.png": "bc2148f971863449cf685fed72caab83",
"assets/assets/images/UI/connection.png": "7660a308ff5023a63a0e4c2be5603e53",
"assets/assets/images/block_6.png": "1f052e054f73896d243b2ce943dfb324",
"assets/assets/images/block_3.png": "4e1e21ef208fc1e3c01482ed343fa337",
"assets/assets/images/blockv2_4.png": "0a794690ed96f291918d7935fdc42de5",
"assets/assets/images/block_8.png": "0a794690ed96f291918d7935fdc42de5",
"assets/assets/images/blockv2_6.png": "1f052e054f73896d243b2ce943dfb324",
"assets/assets/images/block_4.png": "0a794690ed96f291918d7935fdc42de5",
"assets/assets/images/blockv2_9.png": "771097a848b84cdd3da18ff0a8278a1e",
"assets/assets/images/block_2.png": "e271757b617f4ec4d746f83a537231fc",
"assets/assets/images/levels/6.png": "26fa0b9db75281f8fc2a46884cbd2f71",
"assets/assets/images/levels/19.png": "4fdd5c9fa66a6817be3b55fb5cf60f28",
"assets/assets/images/levels/16.png": "b40db78448e801cdce613304d1f02bff",
"assets/assets/images/levels/31.png": "39f681c23f4bc159d97c01a174e536d4",
"assets/assets/images/levels/44.png": "3d81726e18b2669d69d51a96d1c69f1a",
"assets/assets/images/levels/18.png": "ed79a16c5e6985f6ed13e9d12815f4d6",
"assets/assets/images/levels/39.png": "a9fa8abd3b8a7997d8a1280eff3abf36",
"assets/assets/images/levels/22.png": "20291d2d3ae93ff1c254d26d4c49a233",
"assets/assets/images/levels/24.png": "706ccc17a4c5f7ec72ec895945745f30",
"assets/assets/images/levels/30.png": "bfb3737945f00ceddc14bc52066530b8",
"assets/assets/images/levels/11.png": "033796c1a6f69df269703e54b8180b25",
"assets/assets/images/levels/45.png": "7b204c944b216e4770bfea19b30ae8fd",
"assets/assets/images/levels/7.png": "ee367f23b8b066aca53ac75d0d712706",
"assets/assets/images/levels/8.png": "a810710a438b60161de2758397103134",
"assets/assets/images/levels/2.png": "faa9206952510232b059a20d45d88ba2",
"assets/assets/images/levels/26.png": "97eb8b6a021a287c1c4acae7117d6c8b",
"assets/assets/images/levels/13.png": "121e0f8b443eb97fd1baaa2743aacd3f",
"assets/assets/images/levels/42.png": "bae30ec6e486e378ecf8669c57b0ae26",
"assets/assets/images/levels/20.png": "f79897d4ee7e19bb81ce013c79840127",
"assets/assets/images/levels/4.png": "7ca95d7ddb3561580274bee2f237b59a",
"assets/assets/images/levels/35.png": "ca403efac2681cb9bfe8285415a18673",
"assets/assets/images/levels/17.png": "eae8cce945350e34aa0a918b3754f8fe",
"assets/assets/images/levels/3.png": "53ba32b0dc68b9484eec1ca8ec4305d2",
"assets/assets/images/levels/36.png": "796d1cba335cebb4a69046f5e0b03778",
"assets/assets/images/levels/43.png": "471c2309b4116d24b30cb24894f8cf67",
"assets/assets/images/levels/33.png": "6178d008d7a35e0fb4ac2e025918865c",
"assets/assets/images/levels/9.png": "84fe0b64811d87249e4a36d44fbeaa9d",
"assets/assets/images/levels/10.png": "0667b7f7621ba537f452d57de940c588",
"assets/assets/images/levels/47.png": "f8b4fbac4bbcb0f40c9906b888034abf",
"assets/assets/images/levels/46.png": "209418bde1c05b5b4569247e8e8437f9",
"assets/assets/images/levels/27.png": "a2e966d23021933f1a02b25c9ce8bf49",
"assets/assets/images/levels/29.png": "030e08e715ffe095b4a528cd7664fc3f",
"assets/assets/images/levels/1.png": "65a9813f04956f9cf974dde7140da140",
"assets/assets/images/levels/14.png": "0499b2df6387961f3c7a9493540c7023",
"assets/assets/images/levels/28.png": "9c5bc3c8c0e21ac3661119b230e23ca6",
"assets/assets/images/levels/5.png": "3db2f17553325080e8a6684b2dde12cf",
"assets/assets/images/levels/37.png": "2b71dd29b9638e3774e679874dac9981",
"assets/assets/images/levels/12.png": "a4774cabd0ee11cc1aeecafba7a3b03f",
"assets/assets/images/levels/21.png": "288aa5dd470c2869b6e5b02fecf63b81",
"assets/assets/images/levels/41.png": "5fcd5d1a753c3ed4aa34875dd3854e7e",
"assets/assets/images/levels/40.png": "e5d41cba4ef1358e043feb985b8481eb",
"assets/assets/images/levels/38.png": "708314608d74095d82a6ed3ce1ca5e05",
"assets/assets/images/levels/34.png": "dd35584fc3d4d3fcba396573fd845417",
"assets/assets/images/levels/32.png": "f2cd93230bf3b323b7516bd4797f8715",
"assets/assets/images/levels/15.png": "5c65abb4c5609495b0c6f63c0e082169",
"assets/assets/images/levels/48.png": "854ee4b470e7ddd879e7500490107d8d",
"assets/assets/images/levels/25.png": "2fc65a96da4d7643b390ae4264af0250",
"assets/assets/images/levels/23.png": "5c6402f649639807dd1ceb86f4501588",
"assets/assets/images/blockv2_3.png": "4e1e21ef208fc1e3c01482ed343fa337",
"assets/assets/images/blockv2_2.png": "e271757b617f4ec4d746f83a537231fc",
"assets/assets/images/blockv2_5.png": "5b318a8a6127d74857123e8245b85ebd",
"assets/assets/images/board/d3.png": "22fcf1af970dfdb733925bfdb56e0fa0",
"assets/assets/images/board/l3.png": "58a6d45d4dc51134bf855338ca07cb28",
"assets/assets/images/board/d1.png": "ae72b101c8d0e5c103ae583c8cd75e5c",
"assets/assets/images/board/l1.png": "452f6cfdb2ee9496c5bdd7a69811fb55",
"assets/assets/images/board/u3.png": "5fa1b121e5f3583cd82604dfdffa30cb",
"assets/assets/images/board/r3.png": "f8a34886c2a737fed791998ac44e8a51",
"assets/assets/images/board/d2.png": "940985f299454f2951421a366aba2924",
"assets/assets/images/board/r1.png": "0105febc7dc227c2e1731b8cdbb79225",
"assets/assets/images/board/r2.png": "2f11e2f3fe5bcc8bf3602c7a8c1b0705",
"assets/assets/images/board/l2.png": "c594278568ac15b9c7dc3773001b2e96",
"assets/assets/images/board/u1.png": "98b4b20db6785e6463b192640a7f9ccd",
"assets/assets/images/board/u2.png": "d3a9d241de6f716d585b1c232867878a",
"assets/assets/images/block_1.png": "4e1e21ef208fc1e3c01482ed343fa337",
"assets/assets/images/plansza3.png": "3855faa5951590311460889c5243259f",
"assets/assets/images/block_9.png": "771097a848b84cdd3da18ff0a8278a1e",
"assets/assets/images/block_5.png": "5b318a8a6127d74857123e8245b85ebd",
"assets/assets/levels/starter/challenge_5.json": "9278094a6aa3d9db4d452cef9148b395",
"assets/assets/levels/starter/challenge_11.json": "3711bae23956a8704f3d7836bfe3c522",
"assets/assets/levels/starter/challenge_3.json": "47901009534b1c186ac6c41e91fd2165",
"assets/assets/levels/starter/challenge_1.json": "ae09c72ffc466a9a7f8eefd3de4c9f95",
"assets/assets/levels/starter/challenge_4.json": "0fba9ce48d304edae78894eb09953db5",
"assets/assets/levels/starter/challenge_6.json": "445485da8bd8c01995b3c81159e8c6f8",
"assets/assets/levels/starter/challenge_9.json": "90564108dca63c632bd9822d100f78dd",
"assets/assets/levels/starter/challenge_10.json": "6c3a3f1f982af8974ae22cbe87ed00e5",
"assets/assets/levels/starter/challenge_2.json": "693031e179c37ed2b9a0544778b64b47",
"assets/assets/levels/starter/challenge_8.json": "93d8a3c18c2cbe9152d21aa87b008799",
"assets/assets/levels/starter/challenge_7.json": "f1708325762c0a312aa44b5dd0befd16",
"assets/assets/levels/starter/challenge_12.json": "ff2e91b490fa50cb0ab33530d68bb0ee",
"assets/assets/levels/junior/challenge_20.json": "e98d00328a8d3408a62ffca9d2cf3937",
"assets/assets/levels/junior/challenge_17.json": "322e5ddd1068a305ec959345c75cdd9b",
"assets/assets/levels/junior/challenge_24.json": "7383f85d4c6b7bc2bf6fd4428bd0a425",
"assets/assets/levels/junior/challenge_19.json": "cafb30d8cf5606e4407f22875f9a2443",
"assets/assets/levels/junior/challenge_16.json": "527e495222d0c79b23875f4d4bd38cf4",
"assets/assets/levels/junior/challenge_15.json": "ee26972a027658848e9d1a04cd26efea",
"assets/assets/levels/junior/challenge_21.json": "047164259a18752383adc4b60e82fda0",
"assets/assets/levels/junior/challenge_23.json": "d4a28946df9271fab9a02749ed2490eb",
"assets/assets/levels/junior/challenge_18.json": "deac97d5927393c4165663e8e3c8a31c",
"assets/assets/levels/junior/challenge_13.json": "0b6d6611995a1e7abb88a0c01ea5e87d",
"assets/assets/levels/junior/challenge_22.json": "564707a9a93690f6d70dd2f5594cb0cb",
"assets/assets/levels/junior/challenge_14.json": "aeddeea50a6896e21f2461f09ee99a92",
"assets/assets/levels/expert/challenge_33.json": "058721e4a3d0155f39a29ee1b0eb78ef",
"assets/assets/levels/expert/challenge_34.json": "6ad4f6e14f2190d24ec258fa8e37c90c",
"assets/assets/levels/expert/challenge_30.json": "970c0066d8ccc972d9334b4a40f48964",
"assets/assets/levels/expert/challenge_32.json": "366e9508cb1ea5ab7dc94de824c6bb09",
"assets/assets/levels/expert/challenge_27.json": "4ac761953c458ea764f16be275d4c7c6",
"assets/assets/levels/expert/challenge_36.json": "f498152e0ffbdf0175dc1bee1c378fc6",
"assets/assets/levels/expert/challenge_25.json": "af144748e88a70d0733eaf7c0d325886",
"assets/assets/levels/expert/challenge_26.json": "39eb9a6371879a772270ead1b5711831",
"assets/assets/levels/expert/challenge_35.json": "d57ecd224b89f00250df5d8ae41a07c4",
"assets/assets/levels/expert/challenge_29.json": "c02a24c549fe0b5ee5cbf4468a351616",
"assets/assets/levels/expert/challenge_28.json": "dbd80da2e94a09da30ea126da640e63c",
"assets/assets/levels/expert/challenge_31.json": "6dd508c6fe1db0b264f867d125b6b1e7",
"assets/assets/levels/master/challenge_45.json": "667f74aa452fd8b52bcace92cc72d41c",
"assets/assets/levels/master/challenge_48.json": "9bcd2f2e13af56487da413066f8ed237",
"assets/assets/levels/master/challenge_42.json": "0d4660f5a3b4e9e1014a461a2648dc5e",
"assets/assets/levels/master/challenge_39.json": "5d8783dd4a3bd148c43ad2cf659b5253",
"assets/assets/levels/master/challenge_38.json": "8fb3c3fd39e7f23d2bcfa5387267e87a",
"assets/assets/levels/master/challenge_40.json": "fbda20353c5b329daaa51681852823f7",
"assets/assets/levels/master/challenge_46.json": "3d96ec09886f111961d5b235fbcce974",
"assets/assets/levels/master/challenge_44.json": "2dd01a3b1893b8a6ad08e01feea9320a",
"assets/assets/levels/master/challenge_43.json": "7f7e0263b9d78fd705a9fc1967b3715f",
"assets/assets/levels/master/challenge_41.json": "0560fdf986a1f6512a9a1801b15dcd8a",
"assets/assets/levels/master/challenge_47.json": "9e1ff14a6c08ebecbc67883abfe5bc79",
"assets/assets/levels/master/challenge_37.json": "b2af1e437f93e84930272ab86ab7cf28",
"assets/assets/audio/effects/win.mp3": "604373c9fe8af4fa0ca994d7dd00e159",
"assets/assets/audio/effects/start.mp3": "3035aeaae7e077554883d1ba7762adf9",
"assets/assets/audio/effects/no_more_moves.mp3": "9a6ebd59266412d4c124ef83f578c7cd",
"assets/assets/audio/effects/no_more_moves_alt.mp3": "d414929c4f6b6a156b2b4058b12d818a",
"assets/assets/audio/effects/hint.mp3": "691c5b010fa8b2cbdd912fe8107d41a6",
"assets/assets/audio/effects/rotate.mp3": "cc39f9df9f366253b60db8666491289c",
"assets/assets/audio/music/background.mp3": "f2230b56ccd2d7e29d67b5e3d0b7073a",
"assets/NOTICES": "ba1640930478d230069d8d2af2e36019",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "32b803a4e145cc25edaf0941ef90572e",
"assets/AssetManifest.bin.json": "8a6b982f50ba93f4cee87d7305e97f1a",
"index.html": "c087d2414c6f429aa4f443d33538919e",
"/": "c087d2414c6f429aa4f443d33538919e",
"manifest.json": "20c3aa6e7ddee22039e82753941fb273",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"version.json": "d36a008dee78dd6a09b4f83a36b96472",
"flutter_bootstrap.js": "028bb6c2d13d8950903b0ff23ba6886f"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
