<template>
  <el-container class="app-container">
    <el-aside width="200px" class="app-aside">
      <div class="app-logo">BillSum</div>
      <el-menu
        :default-active="currentRoute"
        router
        class="app-menu"
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409eff"
      >
        <el-menu-item index="/transfer" v-if="canShow('/transfer')">
          <el-icon><Upload /></el-icon>
          <span>数据传输</span>
        </el-menu-item>
        <el-menu-item index="/query">
          <el-icon><Search /></el-icon>
          <span>日志查询</span>
        </el-menu-item>
        <el-menu-item index="/stats">
          <el-icon><DataAnalysis /></el-icon>
          <span>数据统计</span>
        </el-menu-item>
        <el-menu-item index="/finance">
          <el-icon><DataAnalysis /></el-icon>
          <span>财务报表</span>
        </el-menu-item>
        <el-menu-item index="/config" v-if="canShow('/config')">
          <el-icon><Setting /></el-icon>
          <span>参数配置</span>
        </el-menu-item>
        <el-menu-item index="/system" v-if="canShow('/system')">
          <el-icon><Monitor /></el-icon>
          <span>系统功能</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <el-main class="app-main">
      <div class="top-bar">
        <span class="top-bar-title">BillSum - 多站点帐单统计</span>
        <span class="top-bar-right">
          <template v-if="currentUser">
            <el-tag size="small" :type="currentUser.role === 'super' ? 'danger' : 'info'">
              {{ currentUser.name || currentUser.username }}
            </el-tag>
            <el-button link type="info" size="small" @click="doLogout" style="color: #bfcbd9; margin-left: 8px;">退出</el-button>
          </template>
          <template v-else>
            <el-button link type="info" size="small" @click="showLogin" style="color: #bfcbd9;">登录</el-button>
          </template>
        </span>
      </div>
      <router-view v-slot="{ Component }">
        <keep-alive>
          <component :is="Component" />
        </keep-alive>
      </router-view>
    </el-main>

    <!-- Login Dialog -->
    <el-dialog v-model="loginVisible" title="用户登录" width="400px" :close-on-click-modal="false" :close-on-press-escape="false" :show-close="false">
      <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" label-width="80px" @keyup.enter="doLogin">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="loginForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="loginForm.password" type="password" show-password placeholder="请输入密码" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" :loading="loginLoading" @click="doLogin">登录</el-button>
      </template>
    </el-dialog>
  </el-container>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Upload, Search, DataAnalysis, Setting, Monitor } from '@element-plus/icons-vue'
import api from './api'

const route = useRoute()
const router = useRouter()
const currentRoute = computed(() => route.path)

// ── Auth state ──
const currentUser = ref(null)
const loginVisible = ref(false)
const loginLoading = ref(false)
const loginFormRef = ref(null)
const loginForm = reactive({ username: '', password: '' })
const loginRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
}

function restoreUser() {
  try {
    const saved = localStorage.getItem('billsum_user')
    if (saved) currentUser.value = JSON.parse(saved)
  } catch { /* ignore */ }
}

function showLogin() {
  loginForm.username = ''
  loginForm.password = ''
  loginVisible.value = true
  setTimeout(() => {
    const inp = document.querySelector('.el-dialog input')
    if (inp) inp.focus()
  }, 200)
}

async function doLogin() {
  const valid = await loginFormRef.value.validate().catch(() => false)
  if (!valid) return
  loginLoading.value = true
  try {
    const { data } = await api.system.login({
      username: loginForm.username,
      password: loginForm.password,
    })
    currentUser.value = data.user
    localStorage.setItem('billsum_user', JSON.stringify(data.user))
    loginVisible.value = false
    ElMessage.success(`欢迎，${data.user.name || data.user.username}`)
    // Redirect to first allowed route if current route is restricted
    if (!canShow(route.path)) router.push('/query')
  } catch (e) {
    ElMessage.error(e.response?.data?.detail || '登录失败')
  } finally {
    loginLoading.value = false
  }
}

function doLogout() {
  currentUser.value = null
  localStorage.removeItem('billsum_user')
  ElMessage.info('已退出')
  showLogin()
}

function canShow(menuPath) {
  if (!currentUser.value) return true // show all before login
  if (currentUser.value.role === 'super') return true
  // normal user: only query, stats, finance
  const allowed = ['/query', '/stats', '/finance']
  return allowed.includes(menuPath)
}

onMounted(() => {
  restoreUser()
  // Show login dialog if no user saved
  if (!currentUser.value) {
    setTimeout(() => showLogin(), 300)
  }
})

// Route guard: redirect normal user away from restricted routes
watch(route, (to) => {
  if (currentUser.value && currentUser.value.role !== 'super') {
    const allowed = ['/query', '/stats', '/finance', '/system']
    if (!allowed.includes(to.path)) {
      router.push('/query')
    }
  }
})
</script>

<style>
html, body, #app {
  margin: 0;
  padding: 0;
  height: 100%;
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;
}
.app-container {
  height: 100vh;
}
.app-aside {
  background: #304156;
  overflow-y: auto;
}
.app-logo {
  height: 60px;
  line-height: 60px;
  text-align: center;
  color: #fff;
  font-size: 20px;
  font-weight: bold;
  letter-spacing: 2px;
}
.app-menu {
  border-right: none;
}
.app-menu .el-menu-item:hover {
  background-color: #263445 !important;
}
.app-menu .el-menu-item.is-active {
  background-color: #263445 !important;
}
.app-main {
  background: #f0f2f5;
  overflow: hidden;
  padding: 0;
  display: flex;
  flex-direction: column;
}
.top-bar {
  height: 40px;
  line-height: 40px;
  background: #fff;
  padding: 0 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #e4e7ed;
  flex-shrink: 0;
}
.top-bar-title {
  font-size: 14px;
  color: #606266;
}
.top-bar-right {
  display: flex;
  align-items: center;
  gap: 4px;
}
.app-main > div:last-child {
  flex: 1;
  min-height: 0;
  padding: 20px 20px 0 20px;
  display: flex;
  flex-direction: column;
}
.app-main > div:last-child > div {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
}
.app-main > div:last-child > div > .el-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 0;
}
.app-main > div:last-child > div > .el-card > .el-card__body {
  flex: 1;
  overflow-y: auto;
  min-height: 0;
}
</style>
