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
            <el-table-column label="操作" width="160" fixed="right">
              <template #default="{ row }">
                <el-button type="primary" link size="small" @click="openEditDialog(row)">编辑</el-button>
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
    </el-tabs>

    <!-- ══ Add/Edit User Dialog ══ -->
    <el-dialog v-model="userDialogVisible" :title="isEditing ? '编辑管理员' : '新增管理员'" width="500px" :close-on-click-modal="false">
      <el-form ref="userFormRef" :model="userForm" :rules="userRules" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" :disabled="isEditing" placeholder="用户名" />
        </el-form-item>
        <el-form-item label="密码" :prop="isEditing ? undefined : 'password'">
          <el-input v-model="userForm.password" type="password" show-password :placeholder="isEditing ? '留空则不修改' : '密码'" />
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
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import api from '../api'

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
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 4, message: '密码至少4位', trigger: 'blur' },
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

onMounted(() => {
  loadBinlog()
  loadUsers()
})
</script>

<style scoped>
.system-view { width: 100%; }
.system-tabs { height: 100%; display: flex; flex-direction: column; }
.system-tabs :deep(.el-tabs__content) { flex: 1; overflow-y: auto; }
.system-tabs :deep(.el-tab-pane) { height: 100%; }
</style>
