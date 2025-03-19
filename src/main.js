import { createApp } from 'vue'
import App from './App.vue'
import { SUPABASE } from './services/supabase'
import ROUTER from './router'

const APP = createApp(App)

// Make Supabase available in all components
APP.config.globalProperties.$supabase = SUPABASE

// Use router
APP.use(ROUTER)

APP.mount('#app')
