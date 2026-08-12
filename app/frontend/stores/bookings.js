import { defineStore } from "pinia"
import { api } from "../lib/api"

export const useBookingsStore = defineStore("bookings", {
  state: () => ({ list: [], suppressions: [], loaded: false, lastError: null }),
  actions: {
    async fetchAll() {
      const data = await api.get("/api/bookings")
      this.list = data.bookings; this.suppressions = data.suppressions; this.loaded = true
    },
    async sendConfirmation(id, email) {
      this.lastError = null
      try {
        const { booking } = await api.post(`/api/bookings/${id}/send_confirmation`, email ? { email } : {})
        this.upsert(booking)
      } catch (e) { this.lastError = e.message }
    },
    upsert(booking) {
      const i = this.list.findIndex((b) => b.id === booking.id)
      i >= 0 ? Object.assign(this.list[i], booking) : this.list.push(booking)
    },
  },
})
