<script setup>
defineProps({ status: String })
const tones = { delivered: "green", retrying: "yellow", failed: "red", pending: "gray", delivering: "gray" }
</script>
<template>
  <span class="badge" :class="tones[status] || 'gray'">{{ status }}</span>
</template>
