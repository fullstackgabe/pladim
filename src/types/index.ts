export interface GoogleUser {
  email: string
  name: string
  avatar: string
  googleId: string
}

export interface Task {
  id: string
  title: string
  points: number
  scheduledDays: number[]
  completedDates: string[]
  createdAt: number
}

export interface Reward {
  id: string
  title: string
  points: number
  createdAt: number
}

export interface Purchase {
  id: string
  rewardId: string
  rewardTitle: string
  cost: number
  purchasedAt: number
}

export interface TaskCompletion {
  id: string
  taskId: string
  taskTitle: string
  points: number
  completedDate: string
  completedAt: number
}

export type TabType = 'agenda' | 'tasks' | 'rewards'
