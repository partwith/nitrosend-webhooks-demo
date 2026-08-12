<script setup>
import { onMounted, reactive } from "vue"
import { useBookingsStore } from "../stores/bookings"
import IntroPanel from "../components/IntroPanel.vue"

const store = useBookingsStore()
const drafts = reactive({})
onMounted(() => store.fetchAll())

async function send(b) {
  await store.sendConfirmation(b.id, drafts[b.id])
  delete drafts[b.id]
}
</script>

<template>
  <div class="mx-auto max-w-3xl px-6 py-10 font-sans">
    <header class="mb-8 flex items-center justify-between">
      <div>
        <p class="text-xs font-bold uppercase tracking-widest text-indigo-600 dark:text-indigo-400">WeTeachMe · Admin</p>
        <h1 class="text-2xl font-bold">Bookings</h1>
      </div>
      <RouterLink to="/" class="text-sm text-indigo-600 underline dark:text-indigo-400">← back to Nitrosend</RouterLink>
    </header>

    <IntroPanel side="wtm" />
    <p v-if="store.lastError" class="alert danger mb-4">{{ store.lastError }}</p>

    <ul class="divide-y divide-stone-200 border-y border-stone-200 dark:divide-border dark:border-border">
      <li v-for="b in store.list" :key="b.id" class="flex flex-wrap items-center gap-3 py-4">
        <div class="min-w-0 flex-1">
          <p class="font-medium">{{ b.learner_name }}</p>
          <input v-model="drafts[b.id]" :placeholder="b.email" class="mt-0.5 w-72 max-w-full bg-transparent font-mono text-xs text-stone-500 outline-none focus:text-stone-900 dark:text-muted dark:focus:text-default" />
        </div>
        <div class="flex items-center gap-3">
          <span v-if="b.email_failed_at" class="rounded bg-red-100 px-2 py-1 text-xs font-semibold text-red-700 dark:bg-red-900/40 dark:text-red-400">
            Email failed — {{ b.failure_reason }}
          </span>
          <span v-else-if="b.confirmation_sent_at" class="text-xs text-stone-500 dark:text-muted">confirmation sent</span>
          <button class="rounded bg-indigo-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-indigo-500 disabled:opacity-40"
                  :disabled="b.suppressed && !drafts[b.id]" @click="send(b)">
            {{ b.confirmation_sent_at || b.email_failed_at ? "Resend" : "Send confirmation" }}
          </button>
        </div>
        <p v-if="b.suppressed" class="w-full text-xs text-red-600 dark:text-red-400">This address is suppressed — Nitrosend will refuse the send. Edit the email to rebook.</p>
      </li>
    </ul>
  </div>
</template>
