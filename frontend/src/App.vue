<template>
  <!-- ══ Login page — full screen, no sidebar ══ -->
  <router-view v-if="isLoginPage" />

  <!-- ══ Main app layout ══ -->
  <el-container v-else class="app-container">
    <el-aside width="200px" class="app-aside">
      <div class="app-logo">BillSumEx</div>
      <el-menu
        :default-active="currentRoute"
        class="app-menu"
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409eff"
        @select="menuClick"
      >
        <el-menu-item index="/transfer">
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
        <el-menu-item index="/config">
          <el-icon><Setting /></el-icon>
          <span>参数配置</span>
        </el-menu-item>
        <el-menu-item index="/system">
          <el-icon><Monitor /></el-icon>
          <span>系统功能</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <el-main class="app-main">
      <div class="top-bar">
        <span class="top-bar-title">BillSum - 多站点帐单统计</span>
        <span class="top-bar-right">
          <el-dropdown v-if="currentUser" trigger="click" @command="handleUserCommand">
            <el-tag size="small" :type="currentUser.role === 'super' ? 'danger' : 'info'" style="cursor:pointer">
              {{ currentUser.name || currentUser.username }}
              <el-icon style="margin-left:4px"><ArrowDown /></el-icon>
            </el-tag>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">修改个人信息</el-dropdown-item>
                <el-dropdown-item command="password">修改密码</el-dropdown-item>
                <el-dropdown-item divided command="logout">退出</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </span>
      </div>
      <router-view v-slot="{ Component }">
        <keep-alive>
          <component :is="Component" />
        </keep-alive>
      </router-view>
    </el-main>

    <!-- ══ Change Password Dialog ══ -->
    <el-dialog v-model="pwdVisible" title="修改密码" width="400px">
      <el-form ref="pwdFormRef" :model="pwdForm" :rules="pwdRules" label-width="80px">
        <el-form-item label="新密码" prop="password">
          <el-input v-model="pwdForm.password" type="password" show-password placeholder="输入新密码" />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirm">
          <el-input v-model="pwdForm.confirm" type="password" show-password placeholder="再次输入新密码" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="pwdVisible = false">取消</el-button>
        <el-button type="primary" :loading="pwdLoading" @click="saveMyPassword">保存</el-button>
      </template>
    </el-dialog>

    <!-- ══ Edit Profile Dialog ══ -->
    <el-dialog v-model="profileVisible" title="修改个人信息" width="450px">
      <el-form ref="profileFormRef" :model="profileForm" label-width="80px">
        <el-form-item label="姓名">
          <el-input v-model="profileForm.name" placeholder="姓名" />
        </el-form-item>
        <el-form-item label="联系方式">
          <el-input v-model="profileForm.contact" placeholder="联系方式" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="profileForm.notes" type="textarea" :rows="3" placeholder="备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="profileVisible = false">取消</el-button>
        <el-button type="primary" :loading="profileLoading" @click="saveMyProfile">保存</el-button>
      </template>
    </el-dialog>
  </el-container>
</template>

<script setup>
import { ref, computed, reactive } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Upload, Search, DataAnalysis, Setting, Monitor, ArrowDown } from '@element-plus/icons-vue'
import api from './api'

const route = useRoute()
const router = useRouter()
const currentRoute = computed(() => route.path)
const isLoginPage = computed(() => route.path === '/login')

const currentUser = computed(() => {
  // route.path as dummy dep to force re-eval on navigation (localStorage not reactive)
  void route.path
  try {
    return JSON.parse(localStorage.getItem('billsum_user'))
  } catch {
    return null
  }
})

const RESTRICTED = ['/transfer', '/config', '/system']

function menuClick(index) {
  const user = currentUser.value
  if (!user || user.role === 'super') {
    router.push(index)
    return
  }
  if (RESTRICTED.includes(index)) {
    ElMessageBox.alert('当前用户无权限访问此功能，请联系超级管理员。', '无权限', {
      type: 'warning', confirmButtonText: '确定', closeOnClickModal: true
    })
  } else {
    router.push(index)
  }
}

// ── User dropdown ──
function handleUserCommand(cmd) {
  if (cmd === 'logout') doLogout()
  else if (cmd === 'password') openPwdDialog()
  else if (cmd === 'profile') openProfileDialog()
}

function doLogout() {
  const user = currentUser.value
  api.system.logout({ username: user?.username || '' }).catch(() => {})
  localStorage.removeItem('billsum_user')
  ElMessage.info('已退出')
  router.replace('/login')
}

// ── Change Password Dialog ──
const pwdVisible = ref(false)
const pwdLoading = ref(false)
const pwdFormRef = ref(null)
const pwdForm = reactive({ password: '', confirm: '' })
const pwdRules = {
  password: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 4, message: '密码至少4位', trigger: 'blur' },
  ],
  confirm: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: (rule, val, cb) => val === pwdForm.password ? cb() : cb(new Error('两次密码不一致')), trigger: 'blur' },
  ],
}

function openPwdDialog() {
  pwdForm.password = ''
  pwdForm.confirm = ''
  pwdVisible.value = true
}

async function saveMyPassword() {
  const valid = await pwdFormRef.value.validate().catch(() => false)
  if (!valid) return
  pwdLoading.value = true
  try {
    await api.system.updateMyPassword(currentUser.value.username, { password: pwdForm.password })
    ElMessage.success('密码已修改')
    pwdVisible.value = false
  } catch (e) {
    ElMessage.error(e.response?.data?.detail || '修改失败')
  } finally {
    pwdLoading.value = false
  }
}

// ── Edit Profile Dialog ──
const profileVisible = ref(false)
const profileLoading = ref(false)
const profileFormRef = ref(null)
const profileForm = reactive({ name: '', contact: '', notes: '' })

function openProfileDialog() {
  const u = currentUser.value
  profileForm.name = u.name || ''
  profileForm.contact = u.contact || ''
  profileForm.notes = u.notes || ''
  profileVisible.value = true
}

async function saveMyProfile() {
  profileLoading.value = true
  try {
    const { data } = await api.system.updateMyProfile(currentUser.value.username, {
      name: profileForm.name,
      contact: profileForm.contact,
      notes: profileForm.notes,
    })
    // Update localStorage user info
    const user = currentUser.value
    user.name = profileForm.name
    localStorage.setItem('billsum_user', JSON.stringify(user))
    ElMessage.success('个人信息已更新')
    profileVisible.value = false
  } catch (e) {
    ElMessage.error(e.response?.data?.detail || '修改失败')
  } finally {
    profileLoading.value = false
  }
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
.el-dropdown-menu__item { font-size: 13px; }
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
