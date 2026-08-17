import { supabase } from './supabase'
import type { Task, Reward, Purchase, TaskCompletion } from '@/types'

const toTask = (row: any): Task => ({
  id: row.id,
  title: row.title,
  points: row.points,
  scheduledDays: row.scheduled_days,
  completedDates: row.completed_dates,
  createdAt: row.created_at,
})

const toReward = (row: any): Reward => ({
  id: row.id,
  title: row.title,
  points: row.points,
  createdAt: row.created_at,
})

const toPurchase = (row: any): Purchase => ({
  id: row.id,
  rewardId: row.reward_id,
  rewardTitle: row.reward_title,
  cost: row.cost,
  purchasedAt: row.purchased_at,
})

const toTaskCompletion = (row: any): TaskCompletion => ({
  id: row.id,
  taskId: row.task_id,
  taskTitle: row.task_title,
  points: row.points,
  completedDate: row.completed_date,
  completedAt: row.completed_at,
})

export const loadUserData = async (userId: string) => {
  const [tasksRes, rewardsRes, purchasesRes, completionsRes] = await Promise.all([
    supabase.from('tasks').select('*').eq('user_id', userId),
    supabase.from('rewards').select('*').eq('user_id', userId),
    supabase.from('reward_history').select('*').eq('user_id', userId),
    supabase.from('task_history').select('*').eq('user_id', userId),
  ])
  return {
    tasks: (tasksRes.data || []).map(toTask),
    rewards: (rewardsRes.data || []).map(toReward),
    purchases: (purchasesRes.data || []).map(toPurchase),
    taskCompletions: (completionsRes.data || []).map(toTaskCompletion),
  }
}

export const upsertProfile = async (userId: string, email: string, name: string, avatar: string) => {
  await supabase.from('profiles').upsert(
    { id: userId, email, name, avatar, created_at: Date.now() },
    { onConflict: 'id' }
  )
}

export const insertTask = async (userId: string, email: string, task: Task) => {
  await supabase.from('tasks').insert({
    id: task.id,
    user_id: userId,
    email,
    title: task.title,
    points: task.points,
    scheduled_days: task.scheduledDays,
    completed_dates: task.completedDates,
    created_at: task.createdAt,
  })
}

export const updateTask = async (userId: string, task: Task) => {
  await supabase.from('tasks').update({
    title: task.title,
    points: task.points,
    scheduled_days: task.scheduledDays,
    completed_dates: task.completedDates,
  }).eq('id', task.id).eq('user_id', userId)
}

export const deleteTask = async (userId: string, taskId: string) => {
  await supabase.from('tasks').delete().eq('id', taskId).eq('user_id', userId)
}

export const insertReward = async (userId: string, email: string, reward: Reward) => {
  await supabase.from('rewards').insert({
    id: reward.id,
    user_id: userId,
    email,
    title: reward.title,
    points: reward.points,
    created_at: reward.createdAt,
  })
}

export const updateReward = async (userId: string, reward: Reward) => {
  await supabase.from('rewards').update({
    title: reward.title,
    points: reward.points,
  }).eq('id', reward.id).eq('user_id', userId)
}

export const deleteReward = async (userId: string, rewardId: string) => {
  await supabase.from('rewards').delete().eq('id', rewardId).eq('user_id', userId)
}

export const insertPurchase = async (userId: string, email: string, purchase: Purchase) => {
  await supabase.from('reward_history').insert({
    id: purchase.id,
    user_id: userId,
    email,
    reward_id: purchase.rewardId,
    reward_title: purchase.rewardTitle,
    cost: purchase.cost,
    purchased_at: purchase.purchasedAt,
  })
}

export const insertTaskCompletion = async (userId: string, email: string, completion: TaskCompletion) => {
  await supabase.from('task_history').insert({
    id: completion.id,
    user_id: userId,
    email,
    task_id: completion.taskId,
    task_title: completion.taskTitle,
    points: completion.points,
    completed_date: completion.completedDate,
    completed_at: completion.completedAt,
  })
}

export const deleteTaskCompletion = async (userId: string, completionId: string) => {
  await supabase.from('task_history').delete().eq('id', completionId).eq('user_id', userId)
}

export const deleteAllUserData = async (userId: string) => {
  await Promise.all([
    supabase.from('tasks').delete().eq('user_id', userId),
    supabase.from('rewards').delete().eq('user_id', userId),
    supabase.from('reward_history').delete().eq('user_id', userId),
    supabase.from('task_history').delete().eq('user_id', userId),
  ])
}
