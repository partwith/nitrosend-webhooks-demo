<script setup>
import { watch } from "vue"
const props = defineProps({ open: Boolean, title: String })
const emit = defineEmits(["close"])
function onKey(e) { if (e.key === "Escape") emit("close") }
watch(() => props.open, (o) => o ? addEventListener("keydown", onKey) : removeEventListener("keydown", onKey))
</script>

<template>
  <Teleport to="body">
    <div v-if="open" class="fixed inset-0 z-50 flex items-start justify-center p-4 sm:pt-24" role="dialog" aria-modal="true">
      <div class="absolute inset-0 bg-stone-900/40 dark:bg-black/60" @click="emit('close')" />
      <div class="relative w-full max-w-lg rounded-xl bg-surface-raised shadow-lg ring-1 ring-border max-sm:min-h-full max-sm:rounded-none">
        <div class="flex items-center justify-between px-5 py-4 border-b border-divider">
          <h2 class="font-semibold">{{ title }}</h2>
          <button class="text-subtle hover:text-default" aria-label="Close" @click="emit('close')">✕</button>
        </div>
        <div class="px-5 py-4"><slot /></div>
      </div>
    </div>
  </Teleport>
</template>
