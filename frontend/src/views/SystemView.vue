<template>
  <div class="system-view">
    <el-tabs v-model="activeTab" type="border-card" class="system-tabs">
      <!-- ════════════ Tab 1: Binlog Management ════════════ -->
      <el-tab-pane label="Binlog 管理" name="binlog">
        <el-card shadow="never" :body-style="{ padding: '20px' }">
          <el-space>
            <el-button type="primary" :loading="loading" @click="loadBinlog">刷新</el-button>
            <el-button type="danger" @click="purgeConfirm">清除 Binlog</el-button>
          </el-space>

          <el-table :data="binlogs" border stripe style="margin-top: 16px; width: 100%">
            <el-table-column prop="Log_name" label="日志文件" />
            <el-table-column prop="File_size" label="大小(bytes)" :formatter="formatSize" />
            <el-table-column prop="Encrypted" label="加密" width="80" />
          </el-table>

          <el-descriptions v-if="totalSize" :column="1" border style="margin-top: 16px; max-width: 400px">
            <el-descriptions-item label="总文件数">{{ binlogs.length }}</el-descriptions-item>
            <el-descriptions-item label="总大小">{{ formatSize(null, null, totalSize) }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-tab-pane>

      <!-- ════════════ Tab 2: Admin Management ════════════ -->
      <el-tab-pane label="管理员管理" name="users">
        <el-card shadow="never" :body-style="{ padding: '20px' }">
          <div style="margin-bottom: 12px">
            <el-button type="primary" @click="openAddDialog">新增管理员</el-button>
            <el-button @click="loadUsers" :loading="usersLoading">刷新</el-button>
          </div>

          <el-table :data="users" border stripe style="width: 100%">
            <el-table-column label="用户名" prop="username" width="100" />
            <el-table-column label="权限" prop="role" width="110">
              <template #default="{ row }">
                <el-tag :type="row.role === 'super' ? 'danger' : 'info'">
                  {{ row.role === 'super' ? '超级管理员' : '普通用户' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="状态" width="80">
              <template #default="{ row }">
                <el-switch
                  :model-value="row.status === 'enabled'"
                  :disabled="isProtected(row.username)"
                  @change="(val) => toggleStatus(row, val)"
                />
              </template>
            </el-table-column>
            <el-table-column label="姓名" prop="name" width="100" />
            <el-table-column label="联系方式" prop="contact" width="160" />
            <el-table-column label="备注" min-width="200" prop="notes" show-overflow-tooltip />
            <el-table-column label="操作" width="220" fixed="right">
              <template #default="{ row }">
                <el-button type="primary" link size="small" @click="openEditDialog(row)">编辑</el-button>
                <el-button type="warning" link size="small" @click="openChangePwd(row)">密码</el-button>
                <el-button type="danger" link size="small" :disabled="isProtected(row.username)" @click="doDelete(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>

          <el-alert type="info" show-icon :closable="false" style="margin-top: 16px">
            <template #title>
              admin 和 query 为系统默认用户，不可删除、不可更改权限、不可禁用。
              admin 拥有所有操作权限，query 仅可操作日志查询、数据统计、财务报表。
            </template>
          </el-alert>
        </el-card>
      </el-tab-pane>

      <!-- ════════════ Tab 3: System Logs ════════════ -->
      <el-tab-pane label="系统日志" name="logs">
        <el-card shadow="never" :body-style="{ padding: '20px' }">
          <!-- Search bar -->
          <el-form :model="logSearch" inline style="margin-bottom:12px;">
            <el-form-item label="时间范围">
              <el-date-picker v-model="logSearch.dateRange" type="daterange"
                range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期"
                value-format="YYYY-MM-DD" style="width:260px" />
            </el-form-item>
            <el-form-item label="内容">
              <el-input v-model="logSearch.keyword" placeholder="用户名/模块/详情" clearable style="width:200px" @keyup.enter="loadLogs(1)" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="loadLogs(1)" :loading="logsLoading">查询</el-button>
              <el-button @click="resetLogSearch">重置</el-button>
            </el-form-item>
            <el-form-item style="margin-left:auto;">
              <el-input-number v-model="clearDays" :min="1" :max="365" size="small" style="width:80px" />
              <el-button type="danger" plain size="small" @click="clearLogsBefore">清除</el-button>
              <el-button type="danger" size="small" @click="clearAllLogs">清空</el-button>
            </el-form-item>
          </el-form>

          <el-table :data="logs" border stripe style="width:100%">
            <el-table-column label="时间" prop="created_at" width="175" />
            <el-table-column label="用户" prop="username" width="90" />
            <el-table-column label="操作" prop="action" width="80">
              <template #default="{ row }">
                <el-tag v-if="row.action === 'login'" size="small" type="success">登录</el-tag>
                <el-tag v-else-if="row.action === 'logout'" size="small" type="info">登出</el-tag>
                <el-tag v-else-if="row.action === 'export'" size="small" type="warning">导出</el-tag>
                <el-tag v-else size="small">{{ row.action }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="功能模块" prop="module" width="120" />
            <el-table-column label="详情" prop="detail" min-width="300" show-overflow-tooltip />
          </el-table>

          <PaginationBar
            :total="logsTotal"
            :current-page="logsPage"
            :page-size="logsPageSize"
            @update:current-page="(p) => loadLogs(p)"
            @update:page-size="(s) => { logsPageSize = s; loadLogs(1) }"
          />
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <!-- ══ Add/Edit User Dialog ══ -->
    <el-dialog v-model="userDialogVisible" :title="isEditing ? '编辑管理员' : '新增管理员'" width="500px" :close-on-click-modal="false">
      <el-form ref="userFormRef" :model="userForm" :rules="userRules" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" :disabled="isEditing" placeholder="用户名" />
        </el-form-item>
        <el-form-item label="密码">
          <el-input v-model="userForm.password" type="password" show-password :placeholder="isEditing ? '留空则不修改' : '密码（必填）'" />
        </el-form-item>
        <el-form-item label="权限" prop="role">
          <el-radio-group v-model="userForm.role">
            <el-radio value="super">超级管理员</el-radio>
            <el-radio value="normal">普通用户</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="userForm.status">
            <el-radio value="enabled">启用</el-radio>
            <el-radio value="disabled">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="userForm.name" placeholder="姓名" />
        </el-form-item>
        <el-form-item label="联系方式">
          <el-input v-model="userForm.contact" placeholder="联系方式" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="userForm.notes" type="textarea" :rows="2" placeholder="备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="userDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="userSaving" @click="saveUser">保存</el-button>
      </template>
    </el-dialog>

    <!-- ══ 改密码对话框（admin 可改任何管理员密码） ══ -->
    <el-dialog v-model="pwdDialogVisible" :title="`修改密码 — ${pwdForm.username}`" width="400px" :close-on-click-modal="false">
      <el-form ref="pwdFormRef" :model="pwdForm" :rules="pwdRules" label-width="80px">
        <el-form-item label="新密码" prop="password">
          <el-input v-model="pwdForm.password" type="password" show-password placeholder="至少4位" />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirm">
          <el-input v-model="pwdForm.confirm" type="password" show-password placeholder="再次输入新密码" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="pwdDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="pwdSaving" @click="saveChangePwd">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import api from '../api'
import PaginationBar from '../components/PaginationBar.vue'

const PROTECTED = ['admin', 'query']
function isProtected(name) { return PROTECTED.includes(name) }

// ── Tab ──
const activeTab = ref('binlog')

// ── Binlog ──
const binlogs = ref([])
const loading = ref(false)
const totalSize = computed(() => binlogs.value.reduce((sum, b) => sum + (b.File_size || 0), 0))

async function loadBinlog() {
  loading.value = true
  try {
    const { data } = await api.system.binlog()
    binlogs.value = data.binlogs || []
  } finally {
    loading.value = false
  }
}

function formatSize(row, col, val) {
  if (!val) return '0'
  if (val > 1073741824) return (val / 1073741824).toFixed(2) + ' GB'
  if (val > 1048576) return (val / 1048576).toFixed(2) + ' MB'
  if (val > 1024) return (val / 1024).toFixed(2) + ' KB'
  return val + ' B'
}

async function purgeConfirm() {
  await ElMessageBox.confirm('确认清除所有 binlog？此操作不可恢复。', '警告',
    { confirmButtonText: '确认清除', cancelButtonText: '取消', type: 'warning' })
  await api.system.purge({})
  ElMessage.success('Binlog 已清除')
  await loadBinlog()
}

// ── User Management ──
const users = ref([])
const usersLoading = ref(false)

async function loadUsers() {
  usersLoading.value = true
  try {
    const { data } = await api.system.users()
    users.value = data.users || []
  } finally {
    usersLoading.value = false
  }
}

async function toggleStatus(row, enabled) {
  const status = enabled ? 'enabled' : 'disabled'
  try {
    await api.system.updateStatus(row.username, { status })
    row.status = status
    ElMessage.success(enabled ? '已启用' : '已禁用')
  } catch (e) {
    ElMessage.error(e.response?.data?.detail || '操作失败')
  }
}

// ── Add / Edit Dialog ──
const userDialogVisible = ref(false)
const isEditing = ref(false)
const userSaving = ref(false)
const userFormRef = ref(null)
const userForm = reactive({
  username: '', password: '', role: 'normal', status: 'enabled',
  name: '', contact: '', notes: '',
})
const origUsername = ref('')

const userRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 2, message: '用户名至少2位', trigger: 'blur' },
  ],
  role: [{ required: true, message: '请选择权限', trigger: 'change' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }],
}

function resetForm() {
  userForm.username = ''
  userForm.password = ''
  userForm.role = 'normal'
  userForm.status = 'enabled'
  userForm.name = ''
  userForm.contact = ''
  userForm.notes = ''
}

function openAddDialog() {
  isEditing.value = false
  resetForm()
  userDialogVisible.value = true
}

function openEditDialog(row) {
  isEditing.value = true
  origUsername.value = row.username
  userForm.username = row.username
  userForm.password = ''
  userForm.role = row.role
  userForm.status = row.status
  userForm.name = row.name || ''
  userForm.contact = row.contact || ''
  userForm.notes = row.notes || ''
  userDialogVisible.value = true
}

async function saveUser() {
  const valid = await userFormRef.value.validate().catch(() => false)
  if (!valid) return
  // Manual password check (add mode: required; edit mode: optional)
  if (!isEditing.value && (!userForm.password || userForm.password.length < 4)) {
    ElMessage.warning('新增用户密码至少4位')
    userSaving.value = false
    return
  }
  userSaving.value = true
  try {
    if (isEditing.value) {
      // Update profile
      await api.system.updateProfile(origUsername.value, {
        name: userForm.name, contact: userForm.contact, notes: userForm.notes,
      })
      // Password (if not empty)
      if (userForm.password) {
        await api.system.updatePassword(origUsername.value, { password: userForm.password })
      }
      // Status
      await api.system.updateStatus(origUsername.value, { status: userForm.status })
      ElMessage.success('已更新')
    } else {
      await api.system.createUser({
        username: userForm.username, password: userForm.password,
        role: userForm.role, status: userForm.status,
        name: userForm.name, contact: userForm.contact, notes: userForm.notes,
      })
      ElMessage.success('已新增')
    }
    userDialogVisible.value = false
    await loadUsers()
  } catch (e) {
    ElMessage.error(e.response?.data?.detail || '保存失败')
  } finally {
    userSaving.value = false
  }
}

async function doDelete(row) {
  await ElMessageBox.confirm(`确认删除用户 "${row.username}"？`, '确认',
    { confirmButtonText: '删除', cancelButtonText: '取消', type: 'warning' })
  try {
    await api.system.deleteUser(row.username)
    ElMessage.success('已删除')
    await loadUsers()
  } catch (e) {
    ElMessage.error(e.response?.data?.detail || '删除失败')
  }
}

// ── 改密码（admin 可改任何管理员密码） ──
const pwdDialogVisible = ref(false)
const pwdSaving = ref(false)
const pwdFormRef = ref(null)
const pwdForm = reactive({ username: '', password: '', confirm: '' })
const pwdRules = {
  password: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 4, message: '密码至少4位', trigger: 'blur' },
  ],
  confirm: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator: (rule, val, cb) => val === pwdForm.password ? cb() : cb(new Error('两次密码不一致')),
      trigger: 'blur',
    },
  ],
}

function openChangePwd(row) {
  pwdForm.username = row.username
  pwdForm.password = ''
  pwdForm.confirm = ''
  pwdDialogVisible.value = true
}

async function saveChangePwd() {
  const valid = await pwdFormRef.value.validate().catch(() => false)
  if (!valid) return
  pwdSaving.value = true
  try {
    await api.system.updatePassword(pwdForm.username, { password: pwdForm.password })
    ElMessage.success(`已修改 ${pwdForm.username} 的密码`)
    pwdDialogVisible.value = false
  } catch (e) {
    ElMessage.error(e.response?.data?.detail || '修改失败')
  } finally {
    pwdSaving.value = false
  }
}

// ── System Logs ──
const logs = ref([])
const logsTotal = ref(0)
const logsPage = ref(1)
const logsPageSize = ref(50)
const logsLoading = ref(false)
const clearDays = ref(30)
const logSearch = reactive({
  dateRange: [],
  keyword: '',
})

function getDefaultDateRange() {
  const now = new Date()
  const start = new Date(now.getFullYear(), now.getMonth(), 1)
  const fmt = (d) => {
    const y = d.getFullYear()
    const m = String(d.getMonth() + 1).padStart(2, '0')
    const day = String(d.getDate()).padStart(2, '0')
    return `${y}-${m}-${day}`
  }
  return [fmt(start), fmt(now)]
}

async function loadLogs(page = 1) {
  logsLoading.value = true
  logsPage.value = page
  try {
    const params = { page, size: logsPageSize.value }
    if (logSearch.dateRange && logSearch.dateRange.length === 2) {
      params.date_start = logSearch.dateRange[0]
      params.date_end = logSearch.dateRange[1]
    }
    if (logSearch.keyword) params.keyword = logSearch.keyword
    const { data } = await api.system.getLogs(params)
    logs.value = data.logs || []
    logsTotal.value = data.total || 0
  } finally {
    logsLoading.value = false
  }
}

function resetLogSearch() {
  logSearch.dateRange = []
  logSearch.keyword = ''
  loadLogs(1)
}

async function clearAllLogs() {
  await ElMessageBox.confirm('确认清空所有系统日志？此操作不可恢复。', '警告',
    { confirmButtonText: '确认清空', cancelButtonText: '取消', type: 'warning' })
  await api.system.clearLogs()
  ElMessage.success('日志已清空')
  loadLogs(1)
}

async function clearLogsBefore() {
  await ElMessageBox.confirm(`确认清除${clearDays.value}日之前的日志？`, '确认',
    { confirmButtonText: '确认清除', cancelButtonText: '取消', type: 'warning' })
  await api.system.clearLogsBefore({ days: clearDays.value })
  ElMessage.success(`已清除${clearDays.value}日之前的日志`)
  loadLogs(1)
}

onMounted(() => {
  loadBinlog()
  loadUsers()
  logSearch.dateRange = getDefaultDateRange()
  loadLogs()
})
</script>

<style scoped>
.system-view { width: 100%; }
.system-tabs { height: 100%; display: flex; flex-direction: column; }
.system-tabs :deep(.el-tabs__content) { flex: 1; overflow-y: auto; }
.system-tabs :deep(.el-tab-pane) { height: 100%; }
</style>
