import { createRouter, createWebHistory } from 'vue-router'
import { ElMessage } from 'element-plus'

const routes = [
  { path: '/login', name: 'login', component: () => import('../views/LoginView.vue'), meta: { title: '登录', public: true } },
  { path: '/', redirect: '/query' },
  { path: '/transfer', name: 'transfer', component: () => import('../views/TransferView.vue'), meta: { title: '数据传输' } },
  { path: '/query', name: 'query', component: () => import('../views/QueryView.vue'), meta: { title: '日志查询' } },
  { path: '/stats', name: 'stats', component: () => import('../views/StatsView.vue'), meta: { title: '数据统计' } },
  { path: '/finance', name: 'finance', component: () => import('../views/FinanceView.vue'), meta: { title: '财务报表' } },
  { path: '/config', name: 'config', component: () => import('../views/ConfigView.vue'), meta: { title: '参数配置' } },
  { path: '/system', name: 'system', component: () => import('../views/SystemView.vue'), meta: { title: '系统功能' } },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// Navigation guard: require login for all routes except /login
const ALLOWED_FOR_NORMAL = ['/query', '/stats', '/finance']

router.beforeEach((to, from, next) => {
  let user = null
  try {
    const saved = localStorage.getItem('billsum_user')
    if (saved) user = JSON.parse(saved)
  } catch { /* ignore */ }

  // Public page — allow
  if (to.meta.public) {
    next()
    return
  }

  // Not logged in — redirect to login
  if (!user) {
    next('/login')
    return
  }

  // Normal user trying to access restricted route — redirect to /query with warning
  if (user.role !== 'super' && !ALLOWED_FOR_NORMAL.includes(to.path)) {
    ElMessage.warning('无权限访问此功能')
    next('/query')
    return
  }

  next()
})

export default router
