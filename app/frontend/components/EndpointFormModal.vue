<script setup>
import { reactive, ref } from "vue"
import AppModal from "./AppModal.vue"
import { useEndpointsStore } from "../stores/endpoints"

defineProps({ open: Boolean })
const emit = defineEmits(["close", "created"])
const store = useEndpointsStore()
const form = reactive({ url: "", description: "", events: ["hard_bounce", "complaint"] })
const error = ref(null)
const saving = ref(false)
const EVENTS = [
  ["hard_bounce", "Hard bounce", "The address doesn't exist. It was added to the suppression list."],
  ["soft_bounce", "Soft bounce", "Temporary failure (full mailbox, greylisting). Not suppressed."],
  ["complaint", "Spam complaint", "The recipient marked the message as spam. Suppressed immediately."],
]

async function submit() {
  saving.value = true; error.value = null
  try {
    const endpoint = await store.create({ ...form })
    emit("created", endpoint); emit("close")
    form.url = ""; form.description = ""
  } catch (e) { error.value = e.message }
  finally { saving.value = false }
}
</script>

<template>
  <AppModal :open="open" title="New endpoint" @close="emit('close')">
    <form class="grid gap-y-6" @submit.prevent="submit">
      <div>
        <label class="mb-1 block text-sm font-medium" for="ep-url">Endpoint URL</label>
        <input id="ep-url" v-model="form.url" class="default-input mono" placeholder="https://api.yourapp.com/webhooks/nitrosend" required />
        <p class="input-hint mt-1">We'll POST signed JSON here. Try a <a class="underline" href="https://webhook.site" target="_blank" rel="noreferrer">webhook.site</a> URL to inspect payloads.</p>
        <p v-if="error" class="input-error mt-1">{{ error }}</p>
      </div>
      <div>
        <label class="mb-1 block text-sm font-medium" for="ep-desc">Description <span class="text-subtle font-normal">(optional)</span></label>
        <input id="ep-desc" v-model="form.description" class="default-input" placeholder="Production booking system" />
      </div>
      <fieldset>
        <legend class="mb-2 text-sm font-medium">Events to send</legend>
        <div class="grid gap-3">
          <label v-for="[value, name, help] in EVENTS" :key="value" class="flex gap-3">
            <input v-model="form.events" type="checkbox" :value="value" class="default-checkbox mt-0.5" />
            <span><span class="block text-sm">{{ name }}</span><span class="block text-xs text-muted">{{ help }}</span></span>
          </label>
        </div>
      </fieldset>
      <div class="flex justify-end gap-2">
        <button type="button" class="button secondary" @click="emit('close')">Cancel</button>
        <button type="submit" class="button primary" :disabled="saving || form.events.length === 0">Create endpoint</button>
      </div>
    </form>
  </AppModal>
</template>
