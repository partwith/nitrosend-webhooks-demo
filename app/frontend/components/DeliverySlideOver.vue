<!-- app/frontend/components/DeliverySlideOver.vue -->
<script setup>
import { computed, onMounted, onUnmounted, ref, watch } from "vue"
import { useRoute, useRouter } from "vue-router"
import { useDeliveriesStore } from "../stores/deliveries"
import StatusBadge from "./StatusBadge.vue"

const route = useRoute()
const router = useRouter()
const store = useDeliveriesStore()
const delivery = computed(() => store.current)
const now = ref(Date.now())
let timer

const verifySnippet = computed(() => `# Verify a Nitrosend webhook (Ruby)
expected = OpenSSL::HMAC.hexdigest("SHA256", signing_secret,
  "#{request.headers["X-Nitrosend-Timestamp"]}.#{request.raw_post}")
ok = ActiveSupport::SecurityUtils.secure_compare(expected,
  request.headers["X-Nitrosend-Signature"])`)

function close() { router.push(`/endpoints/${route.params.id}`) }
function onKey(e) { if (e.key === "Escape") close() }
function retryIn(d) {
  if (!d.next_retry_at) return null
  const s = Math.max(0, Math.round((new Date(d.next_retry_at) - now.value) / 1000))
  return s > 90 ? `${Math.round(s / 60)}m` : `${s}s`
}

onMounted(() => {
  store.fetchOne(route.params.deliveryId)
  addEventListener("keydown", onKey)
  timer = setInterval(() => (now.value = Date.now()), 1000)
})
onUnmounted(() => { removeEventListener("keydown", onKey); clearInterval(timer) })
watch(() => route.params.deliveryId, (id) => id && store.fetchOne(id))
</script>

<template>
  <aside class="fixed inset-y-0 right-0 z-50 w-full max-w-xl overflow-y-auto border-l border-border bg-surface shadow-xl dark:shadow-none">
    <div v-if="delivery" class="p-6">
      <div class="mb-6 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <h2 class="font-semibold">{{ delivery.event.event_type.replace("_", " ") }} delivery</h2>
          <StatusBadge :status="delivery.status" />
        </div>
        <button class="text-subtle hover:text-default" aria-label="Close" @click="close">✕</button>
      </div>

      <p class="eyebrow mb-2">Attempts</p>
      <ol class="mb-6 grid gap-2">
        <li v-for="a in delivery.attempts" :key="a.number" class="rounded-lg bg-surface-sunken px-4 py-3 text-sm">
          <div class="flex items-center gap-3">
            <span class="font-medium">#{{ a.number }}</span>
            <span class="mono">{{ a.http_status ?? "no response" }}</span>
            <span v-if="a.latency_ms" class="text-muted">{{ a.latency_ms }}ms</span>
            <span class="ml-auto text-xs text-muted">{{ new Date(a.created_at).toLocaleTimeString() }}</span>
          </div>
          <p v-if="a.error" class="mt-1 text-xs text-red-600 dark:text-red-400 mono">{{ a.error }}</p>
          <p v-else-if="a.response_excerpt" class="mt-1 truncate text-xs text-muted mono">{{ a.response_excerpt }}</p>
        </li>
        <li v-if="delivery.status === 'retrying'" class="rounded-lg border border-dashed border-border-strong px-4 py-3 text-sm text-muted">
          Next attempt in {{ retryIn(delivery) }}
        </li>
      </ol>

      <p class="eyebrow mb-2">Request payload</p>
      <pre class="mb-6 overflow-x-auto rounded-lg bg-surface-sunken p-4 text-xs mono">{{ JSON.stringify(delivery.event.payload, null, 2) }}</pre>

      <p class="eyebrow mb-2">Headers sent</p>
      <pre class="mb-6 overflow-x-auto rounded-lg bg-surface-sunken p-4 text-xs mono">{{ Object.entries(delivery.attempts.at(-1)?.request_headers || {}).map(([k, v]) => `${k}: ${v}`).join("\n") }}</pre>

      <p class="eyebrow mb-2">Verifying the signature</p>
      <pre class="overflow-x-auto rounded-lg bg-surface-sunken p-4 text-xs mono">{{ verifySnippet }}</pre>
    </div>
  </aside>
</template>
