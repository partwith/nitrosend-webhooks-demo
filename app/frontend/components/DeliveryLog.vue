<!-- app/frontend/components/DeliveryLog.vue -->
<script setup>
import { computed, onMounted } from "vue"
import { useRouter } from "vue-router"
import { useDeliveriesStore } from "../stores/deliveries"
import StatusBadge from "./StatusBadge.vue"

const props = defineProps({ endpointId: [String, Number] })
const store = useDeliveriesStore()
const router = useRouter()
const deliveries = computed(() => store.byEndpoint[props.endpointId] || [])
onMounted(() => store.fetchForEndpoint(props.endpointId))

function age(iso) {
  const s = Math.round((Date.now() - new Date(iso)) / 1000)
  if (s < 60) return `${s}s ago`
  const m = Math.round(s / 60)
  return m < 60 ? `${m}m ago` : `${Math.round(m / 60)}h ago`
}
</script>

<template>
  <section class="card">
    <div class="card-header">
      <h2 class="card-title">Delivery log</h2>
      <p class="card-subtitle">Every attempt to reach this endpoint, live.</p>
    </div>
    <div v-if="deliveries.length === 0" class="card-body py-10 text-center text-sm text-muted">
      Nothing delivered yet. Send a test event, or trigger a real bounce from the WeTeachMe demo.
    </div>
    <div v-else class="overflow-x-auto">
      <table class="table-base">
        <thead><tr><th>Event</th><th>Response</th><th>Attempts</th><th>Status</th><th>When</th></tr></thead>
        <tbody>
          <tr v-for="d in deliveries" :key="d.id" :class="{ 'row-pulse': store.pulseIds.has(d.id) }"
              @click="router.push(`/endpoints/${endpointId}/deliveries/${d.id}`)">
            <td class="whitespace-nowrap">
              <span class="text-sm">{{ d.event.event_type.replace("_", " ") }}</span>
              <span class="block text-xs text-muted mono">{{ d.event.recipient || "test event" }}</span>
            </td>
            <td class="mono whitespace-nowrap">{{ d.last_attempt?.http_status ?? (d.last_attempt?.error ? "ERR" : "—") }}</td>
            <td class="whitespace-nowrap text-muted">{{ d.attempts_count }}</td>
            <td class="whitespace-nowrap"><StatusBadge :status="d.status" /></td>
            <td class="whitespace-nowrap text-muted">{{ age(d.created_at) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>
