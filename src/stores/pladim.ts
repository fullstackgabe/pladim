import { defineStore } from 'pinia'

const shortId = () => Math.floor(100000 + Math.random() * 900000).toString()
import type { Task, Reward, GoogleUser, Purchase, TaskCompletion } from '@/types'
import { supabase } from '@/services/supabase'
import {
  loadUserData,
  upsertProfile,
  insertTask,
  updateTask as dbUpdateTask,
  deleteTask,
  insertReward,
  updateReward as dbUpdateReward,
  deleteReward,
  insertPurchase,
  insertTaskCompletion,
  deleteTaskCompletion,
  deleteAllUserData,
} from '@/services/storage'
import { useToast } from '@/components/ui/ToastContainer.vue'

export const usePladimStore = defineStore('pladim', {
  state: () => ({
    user: null as GoogleUser | null,
    userId: null as string | null,
    tasks: [] as Task[],
    rewards: [] as Reward[],
    purchases: [] as Purchase[],
    taskCompletions: [] as TaskCompletion[],
    loading: false,
    authReady: false,
  }),

  getters: {
    pointsFromTasks: (state): number =>
      state.taskCompletions.reduce((total, c) => total + c.points, 0),

    spentPoints: (state): number =>
      state.purchases.reduce((total, purchase) => total + purchase.cost, 0),

    totalBalance(): number {
      return this.pointsFromTasks - this.spentPoints
    },
  },

  actions: {
    async checkSession() {
      const { data: { session } } = await supabase.auth.getSession()
      if (session) {
        await this.handleSession(session)
      }
      this.authReady = true
      return !!session
    },

    async handleSession(session: any) {
      const meta = session.user.user_metadata
      this.userId = session.user.id
      this.user = {
        email: session.user.email,
        name: meta.full_name || meta.name || session.user.email,
        avatar: meta.avatar_url || meta.picture || '',
        googleId: meta.sub || '',
      }
      await upsertProfile(this.userId!, this.user.email, this.user.name, this.user.avatar)
      await this.loadData()
    },

    async loadData() {
      if (!this.userId) return
      this.loading = true
      try {
        const data = await loadUserData(this.userId)
        this.tasks = data.tasks
        this.rewards = data.rewards
        this.purchases = data.purchases
        this.taskCompletions = data.taskCompletions
      } finally {
        this.loading = false
      }
    },

    async logout() {
      await supabase.auth.signOut()
    },

    async addTask(title: string, points: number, scheduledDays: number[]) {
      if (!this.userId) return
      const task: Task = {
        id: shortId(),
        title,
        points,
        scheduledDays,
        completedDates: [],
        createdAt: Date.now(),
      }
      this.tasks.push(task)
      await insertTask(this.userId, this.user!.email, task)
      useToast().add({ title: 'Sucesso', message: 'Tarefa criada!', type: 'success' })
    },

    async removeTask(id: string) {
      if (!this.userId) return
      this.tasks = this.tasks.filter(t => t.id !== id)
      await deleteTask(this.userId, id)
      useToast().add({ title: 'Sucesso', message: 'Tarefa removida!', type: 'success' })
    },

    async updateTask(id: string, updates: Partial<Task>) {
      if (!this.userId) return
      const task = this.tasks.find(t => t.id === id)
      if (task) {
        Object.assign(task, updates)
        await dbUpdateTask(this.userId, task)
      }
    },

    async toggleTaskDate(taskId: string, dateString: string) {
      if (!this.userId) return
      const task = this.tasks.find(t => t.id === taskId)
      if (task) {
        const index = task.completedDates.indexOf(dateString)
        if (index > -1) {
          task.completedDates.splice(index, 1)
          const completion = this.taskCompletions.find(c => c.taskId === taskId && c.completedDate === dateString)
          if (completion) {
            this.taskCompletions = this.taskCompletions.filter(c => c.id !== completion.id)
            await deleteTaskCompletion(this.userId!, completion.id)
          }
        } else {
          task.completedDates.push(dateString)
          const completion: TaskCompletion = {
            id: shortId(),
            taskId: task.id,
            taskTitle: task.title,
            points: task.points,
            completedDate: dateString,
            completedAt: Date.now(),
          }
          this.taskCompletions.push(completion)
          await insertTaskCompletion(this.userId!, this.user!.email, completion)
        }
        await dbUpdateTask(this.userId, task)
      } else {
        const completion = this.taskCompletions.find(c => c.taskId === taskId && c.completedDate === dateString)
        if (completion) {
          this.taskCompletions = this.taskCompletions.filter(c => c.id !== completion.id)
          await deleteTaskCompletion(this.userId!, completion.id)
        }
      }
    },

    async addReward(title: string, points: number) {
      if (!this.userId) return
      const reward: Reward = {
        id: shortId(),
        title,
        points,
        createdAt: Date.now(),
      }
      this.rewards.push(reward)
      await insertReward(this.userId, this.user!.email, reward)
      useToast().add({ title: 'Sucesso', message: 'Recompensa criada!', type: 'success' })
    },

    async removeReward(id: string) {
      if (!this.userId) return
      this.rewards = this.rewards.filter(r => r.id !== id)
      await deleteReward(this.userId, id)
      useToast().add({ title: 'Sucesso', message: 'Recompensa removida!', type: 'success' })
    },

    async updateReward(id: string, updates: Partial<Reward>) {
      if (!this.userId) return
      const reward = this.rewards.find(r => r.id === id)
      if (reward) {
        Object.assign(reward, updates)
        await dbUpdateReward(this.userId, reward)
      }
    },

    async purchaseReward(reward: Reward) {
      if (!this.userId) return
      if (this.totalBalance >= reward.points) {
        const purchase: Purchase = {
          id: shortId(),
          rewardId: reward.id,
          rewardTitle: reward.title,
          cost: reward.points,
          purchasedAt: Date.now(),
        }
        this.purchases.push(purchase)
        await insertPurchase(this.userId, this.user!.email, purchase)
        useToast().add({ title: 'Resgatado!', message: `Você pegou "${reward.title}"`, type: 'success' })
      } else {
        useToast().add({ title: 'Saldo insuficiente', message: 'Faltam pontos para essa recompensa.', type: 'error' })
      }
    },

    async resetData() {
      if (!this.userId) return
      this.tasks = []
      this.rewards = []
      this.purchases = []
      this.taskCompletions = []
      await deleteAllUserData(this.userId)
    },
  }
})
