<script setup>
import { computed, onMounted } from "vue"
import { useRoute } from "vue-router"
import { subscribeWorkspace } from "./lib/cable"
import { useDeliveriesStore } from "./stores/deliveries"
import { useBookingsStore } from "./stores/bookings"

const route = useRoute()
const isWtm = computed(() => route.path.startsWith("/wtm"))
const deliveries = useDeliveriesStore()
const bookings = useBookingsStore()

function toggleDark() { document.documentElement.classList.toggle("dark") }

onMounted(() => {
  subscribeWorkspace((msg) => {
    if (msg.type === "delivery.updated") deliveries.upsert(msg.data)
    if (msg.type === "booking.updated") bookings.upsert(msg.data)
  })
})
</script>

<template>
  <div class="min-h-screen" :class="isWtm ? 'bg-stone-100 dark:bg-surface-sunken' : 'bg-page-tint'">
    <header v-if="!isWtm" class="border-b border-border bg-surface">
      <div class="mx-auto flex h-14 max-w-5xl items-center gap-6 px-6">
        <span class="font-semibold text-brand-500">nitrosend</span>
        <nav class="flex items-center gap-4 text-sm font-medium text-muted">
          <RouterLink to="/" class="text-default">Webhooks</RouterLink>
        </nav>
        <div class="ml-auto flex items-center gap-2">
          <RouterLink to="/wtm" class="button ghost sm">Open WeTeachMe demo ↗</RouterLink>
          <button class="button ghost sm" aria-label="Toggle dark mode" @click="toggleDark">◐</button>
        </div>
      </div>
    </header>
    <RouterView />
  </div>
</template>
