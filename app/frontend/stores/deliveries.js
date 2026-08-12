import { defineStore } from "pinia"
import { api } from "../lib/api"

export const useDeliveriesStore = defineStore("deliveries", {
  state: () => ({ byEndpoint: {}, current: null, pulseIds: new Set() }),
  actions: {
    async fetchForEndpoint(endpointId) {
      const { deliveries } = await api.get(`/api/endpoints/${endpointId}/deliveries`)
      this.byEndpoint[endpointId] = deliveries
    },
    async fetchOne(id) {
      const { delivery } = await api.get(`/api/deliveries/${id}`)
      this.current = delivery
      return delivery
    },
    // Cable merge: update in place if present, else prepend (DESIGN.md live-data rule)
    upsert(delivery) {
      const list = this.byEndpoint[delivery.endpoint_id]
      if (list) {
        const i = list.findIndex((d) => d.id === delivery.id)
        if (i >= 0) Object.assign(list[i], delivery)
        else list.unshift(delivery)
      }
      if (this.current?.id === delivery.id) this.fetchOne(delivery.id)
      this.pulseIds.add(delivery.id)
      setTimeout(() => this.pulseIds.delete(delivery.id), 1500)
    },
  },
})
