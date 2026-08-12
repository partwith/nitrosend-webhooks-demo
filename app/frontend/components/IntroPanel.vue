<script setup>
import { ref } from "vue"
const props = defineProps({ side: String })
const key = `intro-dismissed-${props.side}`
const visible = ref(!localStorage.getItem(key))
function dismiss() { localStorage.setItem(key, "1"); visible.value = false }
</script>

<template>
  <div v-if="visible" class="alert info mb-6 flex items-start justify-between gap-4">
    <p v-if="side === 'nitrosend'" class="font-normal">
      <strong>60-second demo:</strong> open the <RouterLink to="/wtm" class="underline">WeTeachMe demo app</RouterLink>, send a booking confirmation to <code class="mono">bounce@simulator.demo</code>, then watch the delivery log here fire — and the booking get flagged over there. This is the feature Nitrosend is missing: suppression events that actually reach the app that sent the email.
    </p>
    <p v-else class="font-normal">
      This is a pretend downstream app that books classes and sends confirmations <em>through</em> Nitrosend. Send a confirmation to <code class="mono">bounce@simulator.demo</code> and watch what a bounce does — because of webhooks, this app finds out.
    </p>
    <button class="shrink-0 underline" @click="dismiss">Dismiss</button>
  </div>
</template>
