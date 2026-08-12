<script setup>
import { computed, onMounted, reactive, watch } from "vue"
import { useRoute } from "vue-router"
import { useEndpointsStore } from "../stores/endpoints"
import SecretCard from "../components/SecretCard.vue"
import DeliveryLog from "../components/DeliveryLog.vue"
import DeliverySlideOver from "../components/DeliverySlideOver.vue"

const route = useRoute()
const store = useEndpointsStore()
const endpoint = computed(() => store.byId(route.params.id))
const form = reactive({ url: "", description: "", events: [], error: null, dirty: false, saving: false })
const EVENTS = [["hard_bounce", "Hard bounce"], ["soft_bounce", "Soft bounce"], ["complaint", "Spam complaint"]]

onMounted(async () => { await store.fetchOne(route.params.id); reset() })
watch(endpoint, (e) => { if (e && !form.dirty) reset() })

function reset() {
  if (!endpoint.value) return
  Object.assign(form, { url: endpoint.value.url, description: endpoint.value.description || "", events: [...endpoint.value.events], dirty: false, error: null })
}
function markDirty() { form.dirty = true }
async function save() {
  form.saving = true; form.error = null
  try { await store.update(endpoint.value.id, { url: form.url, description: form.description, events: form.events }); form.dirty = false }
  catch (e) { form.error = e.message }
  finally { form.saving = false }
}
async function toggleEnabled() {
  await store.update(endpoint.value.id, { enabled: !endpoint.value.enabled })
}
</script>

<template>
  <div v-if="endpoint" class="mx-auto max-w-5xl px-6 py-8">
    <RouterLink to="/" class="text-sm text-muted hover:text-default">← Webhooks</RouterLink>
    <div class="mt-2 mb-6 flex items-center justify-between gap-4">
      <h1 class="mono truncate text-lg font-semibold">{{ endpoint.url }}</h1>
      <!-- Test-event button mounts here in Task 16 -->
    </div>

    <div class="grid gap-6">
      <section class="card">
        <div class="card-header flex items-center justify-between">
          <div>
            <h2 class="card-title">Configuration</h2>
            <p class="card-subtitle">Which suppression events this endpoint receives.</p>
          </div>
          <button class="input-switch" :class="{ checked: endpoint.enabled }" role="switch" :aria-checked="endpoint.enabled" @click="toggleEnabled">
            <span class="knob" />
          </button>
        </div>
        <form class="card-body grid gap-y-6" @submit.prevent="save">
          <div>
            <label class="mb-1 block text-sm font-medium" for="url">Endpoint URL</label>
            <input id="url" v-model="form.url" class="default-input mono" @input="markDirty" />
            <p v-if="form.error" class="input-error mt-1">{{ form.error }}</p>
          </div>
          <div>
            <label class="mb-1 block text-sm font-medium" for="desc">Description</label>
            <input id="desc" v-model="form.description" class="default-input" @input="markDirty" />
          </div>
          <fieldset class="flex flex-wrap gap-x-6 gap-y-2">
            <label v-for="[value, name] in EVENTS" :key="value" class="flex items-center gap-2 text-sm">
              <input v-model="form.events" type="checkbox" :value="value" class="default-checkbox" @change="markDirty" />{{ name }}
            </label>
          </fieldset>
          <div v-if="form.dirty" class="flex justify-end gap-2">
            <button type="button" class="button secondary" @click="reset">Discard</button>
            <button type="submit" class="button primary" :disabled="form.saving || form.events.length === 0">Save changes</button>
          </div>
        </form>
      </section>

      <SecretCard :endpoint="endpoint" />

      <DeliveryLog :endpoint-id="route.params.id" />
    </div>

    <DeliverySlideOver v-if="route.params.deliveryId" />
  </div>
</template>
