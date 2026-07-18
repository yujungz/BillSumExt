import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  timeout: 7200000,
})

export default {
  // Transfer
  transfer: {
    export: (data) => api.post('/transfer/export', data),
    download: (data) => api.post('/transfer/download', data),
    import: (data) => api.post('/transfer/import', data),
    fill: (data) => api.post('/transfer/fill', data),
    all: (data) => api.post('/transfer/all', data),
    asyncAll: (data) => api.post('/transfer/async-all', data),
    asyncFill: (data) => api.post('/transfer/async-fill', data),
    taskStatus: (taskId) => api.get('/transfer/task-status', { params: { task_id: taskId } }),
    uptcustomer: (data) => api.post('/transfer/uptcustomer', data),
  },
  // 数据传导 (DB→DB backup/transfer)
  conduction: {
    getConfig: () => api.get('/conduction/config'),
    saveConfig: (data) => api.put('/conduction/config', data),
    testSsh: (data) => api.post('/conduction/test-ssh', data),
    testDb: (data) => api.post('/conduction/test-db', data),
    refreshTables: (data) => api.post('/conduction/refresh-tables', data),
    start: (data) => api.post('/conduction/start', data),
    taskStatus: (taskId) => api.get('/conduction/task-status', { params: { task_id: taskId } }),
    download: (taskId) => api.get('/conduction/download', { params: { task_id: taskId }, responseType: 'blob' }),
  },
  // Finance
  finance: {
    logTables: (site) => api.get('/finance/log-tables', { params: { site } }),
    usernames: (site, table) => api.get('/finance/usernames', { params: { site, table } }),
    tableDates: (table) => api.get('/finance/table-dates', { params: { table } }),
    supplier: (params) => api.get('/finance/supplier', { params }),
    supplierExport: (params) => api.get('/finance/supplier/export', { params, responseType: 'blob' }),
    supplierQueryAsync: (data) => api.post('/finance/supplier/query-async', data),
    supplierQueryStatus: (taskId) => api.get('/finance/supplier/query-status', { params: { task_id: taskId } }),
    supplierQueryResult: (taskId) => api.get('/finance/supplier/query-result', { params: { task_id: taskId } }),
    userStats: (params) => api.get('/finance/user-stats', { params }),
    userStatsQueryAsync: (data) => api.post('/finance/user-stats/query-async', data),
    userStatsQueryStatus: (taskId) => api.get('/finance/user-stats/query-status', { params: { task_id: taskId } }),
    userStatsQueryResult: (taskId) => api.get('/finance/user-stats/query-result', { params: { task_id: taskId } }),
    userStatsDetail: (params) => api.get('/finance/user-stats/detail', { params }),
    userStatsExport: (params) => api.get('/finance/user-stats/export', { params, responseType: 'blob' }),
    exportAsync: (data) => api.post('/finance/user-stats/export-async', data),
    exportStatus: (taskId) => api.get('/finance/user-stats/export-status', { params: { task_id: taskId } }),
    exportDownload: (taskId) => api.get('/finance/user-stats/export-download', { params: { task_id: taskId }, responseType: 'blob' }),
    siteReportPreview: (params) => api.get('/finance/site-report/preview', { params }),
    siteReportPreviewAsync: (data) => api.post('/finance/site-report/preview-async', data),
    siteReportPreviewStatus: (taskId) => api.get('/finance/site-report/preview-status', { params: { task_id: taskId } }),
    siteReportPreviewResult: (taskId) => api.get('/finance/site-report/preview-result', { params: { task_id: taskId } }),
    siteReportGenerate: (data) => api.post('/finance/site-report/generate', data),
    siteReportZip: (data) => api.post('/finance/site-report/generate-zip', data, { responseType: 'arraybuffer' }),
    siteReportZipAsync: (data) => api.post('/finance/site-report/generate-zip-async', data),
    siteReportZipStatus: (taskId) => api.get('/finance/site-report/generate-zip-status', { params: { task_id: taskId } }),
    siteReportZipDownload: (taskId) => api.get('/finance/site-report/generate-zip-download', { params: { task_id: taskId }, responseType: 'arraybuffer' }),
  },

  // Query
  query: {
    tables: (site, type = 'raw') => api.get('/query/tables', { params: { site, type } }),
    logTables: (site) => api.get('/query/log-tables', { params: { site } }),
    columns: (site, table) => api.get('/query/columns', { params: { site, table } }),
    data: (site, table, page = 1, size = 50, filters = null, timeOrder = null) => {
      const params = { site, table, page, size }
      if (filters) params.filters = JSON.stringify(filters)
      if (timeOrder) params.time_order = timeOrder
      return api.get('/query/data', { params })
    },
    deleteTable: (site, table) => api.delete('/query/table', { params: { site, table } }),
    importTable: (site, table, formData, overwrite = false) => api.post('/query/import', formData, { params: { site, table, overwrite }, headers: { 'Content-Type': 'multipart/form-data' } }),
    exportAsync: (params) => api.post('/query/export-async', null, { params }),
    exportStatus: (taskId) => api.get('/query/export-status', { params: { task_id: taskId } }),
    exportDownload: (taskId) => api.get('/query/export-download', { params: { task_id: taskId }, responseType: 'blob' }),
  },
  // Stats
  stats: {
    query: (data) => api.post('/stats/query', data),
    queryAsync: (data) => api.post('/stats/query-async', data),
    queryStatus: (taskId) => api.get('/stats/query-status', { params: { task_id: taskId } }),
    queryResult: (taskId) => api.get('/stats/query-result', { params: { task_id: taskId } }),
    distinct: (site, table, field) => api.get('/stats/distinct', { params: { site, table, field } }),
    exportDetail: (data) => api.post('/stats/export-detail', data, { responseType: 'blob' }),
    exportDetailAsync: (data) => api.post('/stats/export-detail-async', data),
    exportDetailStatus: (taskId) => api.get('/stats/export-detail-status', { params: { task_id: taskId } }),
    exportDetailDownload: (taskId) => api.get('/stats/export-detail-download', { params: { task_id: taskId }, responseType: 'blob' }),
    exportAsync: (data) => api.post('/stats/export-async', data),
    exportStatus: (taskId) => api.get('/stats/export-status', { params: { task_id: taskId } }),
    exportDownload: (taskId) => api.get('/stats/export-download', { params: { task_id: taskId }, responseType: 'blob' }),
  },
  // Settings
  settings: {
    get: () => api.get('/settings'),
    save: (data) => api.put('/settings', data),
    testMysql: (data) => api.post('/settings/test-mysql', data),
    testSsh: (data) => api.post('/settings/test-ssh', data),
    testRemoteDb: (data) => api.post('/settings/test-remote-db', data),
    mountKey: (formData) => api.post('/settings/mount-key', formData, { headers: { 'Content-Type': 'multipart/form-data' } }),
  },
  // System
  system: {
    binlog: () => api.get('/system/binlog'),
    purge: (data) => api.post('/system/binlog/purge', data),
    undo: () => api.get('/system/undo'),
    undoSetInactive: (data) => api.post('/system/undo/set-inactive', data),
    undoSetActive: (data) => api.post('/system/undo/set-active', data),
    undoCreate: (data) => api.post('/system/undo/create', data),
    undoDrop: (data) => api.post('/system/undo/drop', data),
    executeSql: (site, formData) => api.post('/system/execute-sql', formData, { params: { site }, headers: { 'Content-Type': 'multipart/form-data' } }),
    users: () => api.get('/system/users'),
    createUser: (data) => api.post('/system/users', data),
    deleteUser: (username) => api.delete(`/system/users/${username}`),
    updatePassword: (username, data) => api.put(`/system/users/${username}/password`, data),
    updateStatus: (username, data) => api.put(`/system/users/${username}/status`, data),
    updateProfile: (username, data) => api.put(`/system/users/${username}/profile`, data),
    updateMyPassword: (username, data) => api.put(`/system/users/me/password?username=${username}`, data),
    updateMyProfile: (username, data) => api.put(`/system/users/me/profile?username=${username}`, data),
    login: (data) => api.post('/system/login', data),
    logout: (data) => api.post('/system/logout', data),
    logAction: (data) => api.post('/system/log-action', data),
    getLogs: (params) => api.get('/system/logs', { params }),
    clearLogs: () => api.delete('/system/logs'),
    clearLogsBefore: (data) => api.post('/system/logs/clear-before', data),
  },
}
