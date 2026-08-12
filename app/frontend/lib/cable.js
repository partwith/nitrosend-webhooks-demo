import { createConsumer } from "@rails/actioncable"
let consumer
export function subscribeWorkspace(onMessage) {
  consumer ||= createConsumer("/cable")
  return consumer.subscriptions.create("WorkspaceChannel", {
    received: (msg) => onMessage(msg),
  })
}
