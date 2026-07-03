<template>
  <!-- ══ Login page — full screen, no sidebar ══ -->
  <router-view v-if="isLoginPage" />

  <!-- ══ Main app layout ══ -->
  <el-container v-else class="app-container">
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
          <el-tag size="small" :type="currentUser.role === 'super' ? 'danger' : 'info'">
            {{ currentUser.name || currentUser.username }}
          </el-tag>
          <el-button link type="info" size="small" @click="doLogout" style="color: #bfcbd9; margin-left: 8px;">退出</el-button>
        </span>
      </div>
      <router-view v-slot="{ Component }">
        <keep-alive>
          <component :is="Component" />
        </keep-alive>
      </router-view>
    </el-main>
  </el-container>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Upload, Search, DataAnalysis, Setting, Monitor } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const currentRoute = computed(() => route.path)
const isLoginPage = computed(() => route.path === '/login')

// Current user from localStorage (reactive by reading on every render)
const currentUser = computed(() => {
  try {
    return JSON.parse(localStorage.getItem('billsum_user'))
  } catch {
    return null
  }
})

function canShow(menuPath) {
  const user = currentUser.value
  if (!user) return false
  if (user.role === 'super') return true
  const allowed = ['/query', '/stats', '/finance']
  return allowed.includes(menuPath)
}

function doLogout() {
  localStorage.removeItem('billsum_user')
  ElMessage.info('已退出')
  router.replace('/login')
}
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
