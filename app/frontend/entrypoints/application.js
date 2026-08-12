import { createApp } from "vue"
import { createPinia } from "pinia"
import "inter-ui/inter-variable.css"
import "@fontsource/jetbrains-mono/400.css"
import "../styles/theme.css"
import "../styles/components.css"
import App from "../App.vue"
import router from "../router"

createApp(App).use(createPinia()).use(router).mount("#app")
