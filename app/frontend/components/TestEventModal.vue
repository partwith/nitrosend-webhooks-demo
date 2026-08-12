<script setup>
import { computed, ref } from "vue"
import { useRouter } from "vue-router"
import AppModal from "./AppModal.vue"
import { useEndpointsStore } from "../stores/endpoints"

const props = defineProps({ open: Boolean, endpoint: Object })
const emit = defineEmits(["close"])
const store = useEndpointsStore()
const router = useRouter()
const eventType = ref("hard_bounce")
const sending = ref(false)

const PREVIEWS = {
  hard_bounce: { reason: "550 5.1.1 user unknown", data: { bounce_type: "Permanent", diagnostic_code: "smtp; 550 5.1.1 user unknown" } },
  soft_bounce: { reason: "452 4.2.2 mailbox full", data: { bounce_type: "Transient", diagnostic_code: "smtp; 452 4.2.2 mailbox full" } },
  complaint: { reason: "abuse", data: { complaint_feedback_type: "abuse" } },
}
const preview = computed(() => JSON.stringify({
  event_id: "evt_…", event_type: eventType.value, occurred_at: new Date().toISOString(),
  message_id: null, recipient: null, ...PREVIEWS[eventType.value], test: true,
}, null, 2))

async function send() {
  sending.value = true
  try {
    const delivery = await store.sendTestEvent(props.endpoint.id, eventType.value)
    emit("close")
    router.push(`/endpoints/${props.endpoint.id}/deliveries/${delivery.id}`)
  } finally { sending.value = false }
}
</script>

<template>
  <AppModal :open="open" title="Send test event" @close="emit('close')">
    <div class="grid gap-y-5">
      <div>
        <label class="mb-1 block text-sm font-medium" for="evt">Event type</label>
        <select id="evt" v-model="eventType" class="default-input">
          <option value="hard_bounce">Hard bounce</option>
          <option value="soft_bounce">Soft bounce</option>
          <option value="complaint">Spam complaint</option>
        </select>
      </div>
      <div>
        <p class="eyebrow mb-2">Payload that will be sent</p>
        <pre class="max-h-64 overflow-auto rounded-lg bg-surface-sunken p-4 text-xs mono">{{ preview }}</pre>
        <p class="input-hint mt-1">Test events go through the real pipeline — signed, delivered, retried — and are marked <code class="mono">"test": true</code>.</p>
      </div>
      <div class="flex justify-end gap-2">
        <button class="button secondary" @click="emit('close')">Cancel</button>
        <button class="button primary" :disabled="sending" @click="send">Send test event</button>
      </div>
    </div>
  </AppModal>
</template>
