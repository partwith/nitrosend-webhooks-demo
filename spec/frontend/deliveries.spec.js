import { describe, it, expect, vi, beforeEach } from "vitest"
import { setActivePinia, createPinia } from "pinia"
import { useDeliveriesStore } from "../../app/frontend/stores/deliveries"

vi.mock("../../app/frontend/lib/api", () => ({ api: { get: vi.fn() } }))

describe("deliveries store upsert", () => {
  beforeEach(() => setActivePinia(createPinia()))

  it("merges an existing delivery in place", () => {
    const s = useDeliveriesStore()
    s.byEndpoint[1] = [{ id: 5, endpoint_id: 1, status: "retrying" }]
    s.upsert({ id: 5, endpoint_id: 1, status: "delivered" })
    expect(s.byEndpoint[1][0].status).toBe("delivered")
    expect(s.byEndpoint[1]).toHaveLength(1)
  })

  it("prepends an unseen delivery and pulses it", () => {
    const s = useDeliveriesStore()
    s.byEndpoint[1] = [{ id: 5, endpoint_id: 1, status: "delivered" }]
    s.upsert({ id: 9, endpoint_id: 1, status: "pending" })
    expect(s.byEndpoint[1][0].id).toBe(9)
    expect(s.pulseIds.has(9)).toBe(true)
  })
})
