<script setup>
import { ref } from "vue"
import AppModal from "./AppModal.vue"
import { useEndpointsStore } from "../stores/endpoints"

const props = defineProps({ endpoint: Object })
const store = useEndpointsStore()
const revealed = ref(false)
const confirming = ref(false)
const copied = ref(false)

async function copy() {
  await navigator.clipboard.writeText(props.endpoint.signing_secret)
  copied.value = true; setTimeout(() => (copied.value = false), 1500)
}
async function rotate() {
  await store.rotateSecret(props.endpoint.id)
  confirming.value = false
}
</script>

<template>
  <section class="card">
    <div class="card-header">
      <h2 class="card-title">Signing secret</h2>
      <p class="card-subtitle">Every delivery is signed with HMAC-SHA256. Verify <code class="mono">X-Nitrosend-Signature</code> before trusting a payload.</p>
    </div>
    <div class="card-body flex flex-wrap items-center gap-3">
      <code class="mono rounded-md bg-surface-sunken px-3 py-2">{{ revealed ? endpoint.signing_secret : "whsec_••••••••••••••••••••••••" }}</code>
      <button class="button secondary sm" @click="revealed = !revealed">{{ revealed ? "Hide" : "Reveal" }}</button>
      <button class="button secondary sm" @click="copy">{{ copied ? "Copied" : "Copy" }}</button>
      <button class="button danger-soft sm ml-auto" @click="confirming = true">Rotate…</button>
    </div>
    <p v-if="endpoint.secret_rotated_at" class="px-5 pb-4 text-xs text-muted">Rotated {{ new Date(endpoint.secret_rotated_at).toLocaleString() }} — the previous secret keeps verifying for 24 hours so in-flight deliveries don't break.</p>

    <AppModal :open="confirming" title="Rotate signing secret?" @close="confirming = false">
      <p class="text-sm text-muted">A new secret is generated immediately. The current secret keeps working for <strong class="text-default">24 hours</strong> so deliveries already in flight still verify — update your receiver within that window.</p>
      <div class="mt-5 flex justify-end gap-2">
        <button class="button secondary" @click="confirming = false">Cancel</button>
        <button class="button danger-soft" @click="rotate">Rotate secret</button>
      </div>
    </AppModal>
  </section>
</template>
