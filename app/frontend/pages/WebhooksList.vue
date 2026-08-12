<script setup>
import { onMounted, ref } from "vue"
import { useRouter } from "vue-router"
import { useEndpointsStore } from "../stores/endpoints"
import EndpointFormModal from "../components/EndpointFormModal.vue"
import IntroPanel from "../components/IntroPanel.vue"

const store = useEndpointsStore()
const router = useRouter()
const showNew = ref(false)
onMounted(() => store.fetchAll())

function relative(iso) {
  if (!iso) return "—"
  const mins = Math.round((Date.now() - new Date(iso)) / 60000)
  if (mins < 1) return "just now"
  if (mins < 60) return `${mins}m ago`
  const h = Math.round(mins / 60)
  return h < 24 ? `${h}h ago` : `${Math.round(h / 24)}d ago`
}
</script>

<template>
  <div class="mx-auto max-w-5xl px-6 py-8">
    <IntroPanel side="nitrosend" />
    <div class="mb-6 flex items-end justify-between">
      <div>
        <h1 class="text-xl font-semibold">Webhooks</h1>
        <p class="card-subtitle mt-1 max-w-xl">Get notified the moment a send bounces or draws a spam complaint — so the system that triggered the send finds out, not just Nitrosend.</p>
      </div>
      <button class="button cta" @click="showNew = true">New endpoint</button>
    </div>

    <div v-if="store.loaded && store.list.length === 0" class="card">
      <div class="card-body py-12 text-center">
        <p class="text-sm font-medium">No endpoints yet</p>
        <p class="mx-auto mt-1 max-w-md text-sm text-muted">Register a URL and Nitrosend will POST a signed event every time an address hard-bounces, soft-bounces, or complains.</p>
      </div>
    </div>

    <div v-else-if="store.loaded" class="card overflow-x-auto">
      <table class="table-base">
        <thead>
          <tr><th>Endpoint</th><th>Events</th><th>Status</th><th>Last delivery</th></tr>
        </thead>
        <tbody>
          <tr v-for="e in store.list" :key="e.id" @click="router.push(`/endpoints/${e.id}`)">
            <td>
              <span class="mono block truncate max-w-sm">{{ e.url }}</span>
              <span v-if="e.description" class="text-xs text-muted">{{ e.description }}</span>
            </td>
            <td class="whitespace-nowrap text-[11px] text-subtle">{{ e.events.map(ev => ev.replace("_", " ")).join(" · ") }}</td>
            <td class="whitespace-nowrap">
              <span v-if="!e.enabled" class="badge gray">disabled</span>
              <span v-else-if="e.recent_failure" class="badge red">failing</span>
              <span v-else class="text-sm text-muted">active</span>
            </td>
            <td class="whitespace-nowrap text-muted">{{ relative(e.last_delivery_at) }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <EndpointFormModal :open="showNew" @close="showNew = false" @created="(e) => router.push(`/endpoints/${e.id}`)" />
  </div>
</template>
