import { createRouter, createWebHistory } from "vue-router"
import WebhooksList from "./pages/WebhooksList.vue"
import EndpointDetail from "./pages/EndpointDetail.vue"
import WtmBookings from "./pages/WtmBookings.vue"

export default createRouter({
  history: createWebHistory(),
  routes: [
    { path: "/", component: WebhooksList },
    { path: "/endpoints/:id", component: EndpointDetail },
    { path: "/endpoints/:id/deliveries/:deliveryId", component: EndpointDetail },
    { path: "/wtm", component: WtmBookings },
  ],
})
