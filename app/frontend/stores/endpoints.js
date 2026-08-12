import { defineStore } from "pinia"
import { api } from "../lib/api"

export const useEndpointsStore = defineStore("endpoints", {
  state: () => ({ list: [], loaded: false }),
  getters: { byId: (s) => (id) => s.list.find((e) => e.id === Number(id)) },
  actions: {
    async fetchAll() { this.list = (await api.get("/api/endpoints")).endpoints; this.loaded = true },
    async fetchOne(id) { this._merge((await api.get(`/api/endpoints/${id}`)).endpoint) },
    async create(attrs) { const { endpoint } = await api.post("/api/endpoints", attrs); this.list.push(endpoint); return endpoint },
    async update(id, attrs) { this._merge((await api.patch(`/api/endpoints/${id}`, attrs)).endpoint) },
    async rotateSecret(id) { this._merge((await api.post(`/api/endpoints/${id}/rotate_secret`)).endpoint) },
    async sendTestEvent(id, eventType) { return (await api.post(`/api/endpoints/${id}/test_events`, { event_type: eventType })).delivery },
    _merge(endpoint) {
      const i = this.list.findIndex((e) => e.id === endpoint.id)
      i >= 0 ? Object.assign(this.list[i], endpoint) : this.list.push(endpoint)
    },
  },
})
