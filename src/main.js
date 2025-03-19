import { createApp } from 'vue'
import App from './App.vue'
import { SUPABASE } from './services/supabase'

const APP = createApp(App)

// Make Supabase available in all components
APP.config.globalProperties.$supabase = SUPABASE

APP.mount('#app')
