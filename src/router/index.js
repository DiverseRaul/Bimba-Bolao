import { createRouter, createWebHistory } from 'vue-router'
import { SUPABASE } from '../services/supabase'
import LoginPage from '../views/LoginPage.vue'
import SignupPage from '../views/SignupPage.vue'

const ROUTES = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/login',
    name: 'LOGIN',
    component: LoginPage,
    meta: { requiresAuth: false }
  },
  {
    path: '/signup',
    name: 'SIGNUP',
    component: SignupPage,
    meta: { requiresAuth: false }
  },
  {
    path: '/dashboard',
    name: 'DASHBOARD',
    component: () => import('../views/DashboardPage.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/profile',
    name: 'SETTINGS',
    component: () => import('../views/ProfilePage.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/group/:id',
    name: 'GROUP',
    component: () => import('../views/GroupPage.vue'),
    meta: { requiresAuth: true }
  }
]

const BASE_URL = '/'

const ROUTER = createRouter({
  history: createWebHistory(BASE_URL),
  routes: ROUTES
})

// Navigation guard to check authentication
ROUTER.beforeEach(async (to, from, next) => {
  const REQUIRES_AUTH = to.matched.some(record => record.meta.requiresAuth)
  const { data } = await SUPABASE.auth.getSession()
  const IS_AUTHENTICATED = !!data.session

  if (REQUIRES_AUTH && !IS_AUTHENTICATED) {
    next('/login')
  } else if (!REQUIRES_AUTH && IS_AUTHENTICATED && (to.path === '/login' || to.path === '/signup')) {
    next('/dashboard')
  } else {
    next()
  }
})

export default ROUTER
