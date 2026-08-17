<template>
  <div class="min-h-screen bg-gray-50 pb-20 font-sans">
    <main class="max-w-5xl mx-auto px-4 py-8"> 
      <HeaderUser :user="store.user" @logout="handleLogout" @reset="handleResetData" />
      <div class="flex flex-col md:flex-row items-center justify-between mb-10 gap-6">
        <div class="text-center md:text-left">
           <h1 class="text-3xl font-bold text-gray-800 mb-2">Planejador de Tarefas</h1>
           <p class="text-gray-500">Transforme sua rotina em um jogo e conquiste suas metas.</p>
        </div>
        <div class="bg-white px-8 py-4 rounded-2xl shadow-sm border border-gray-100 flex flex-col items-center w-full md:w-auto md:min-w-[200px] transform hover:scale-105 transition-transform duration-300">
          <span class="text-gray-500 text-xs font-bold uppercase tracking-widest">Pontos Acumulados</span>
          <span class="text-4xl font-black mt-1" :class="store.totalBalance < 0 ? 'text-red-500' : 'text-teal-600'">{{ store.totalBalance }}</span>
        </div>
      </div>
      <div class="flex rounded-xl overflow-hidden bg-white shadow-sm border border-gray-200 mb-6">
        <button 
          v-for="tab in tabs" 
          :key="tab.id"
          @click="activeTab = tab.id"
          class="flex-1 py-3 px-2 flex items-center justify-center transition-all cursor-pointer relative"
          :class="activeTab === tab.id ? 'bg-teal-50 text-teal-700' : 'text-gray-500 hover:bg-gray-50'"
          :title="tab.label"
        >
          <component :is="tab.icon" class="w-6 h-6" />
          <div v-if="activeTab === tab.id" class="absolute bottom-0 left-0 w-full h-1 bg-teal-500"></div>
        </button>
      </div>
      <div class="mt-4 min-h-[400px]">
        <Transition
          enter-active-class="transition duration-200 ease-out"
          enter-from-class="opacity-0 translate-y-2"
          enter-to-class="opacity-100 translate-y-0"
          leave-active-class="transition duration-150 ease-in"
          leave-from-class="opacity-100 translate-y-0"
          leave-to-class="opacity-0 translate-y-2"
          mode="out-in"
        >
          <div v-if="activeTab === 'agenda'" key="agenda">
            <AgendaTab
              :tasks="store.tasks"
              :task-completions="store.taskCompletions"
              @toggle-date="handleToggleDate"
            />
          </div>
          <div v-else-if="activeTab === 'tasks'" key="tasks">
            <TaskTab
              :tasks="store.tasks"
              :task-completions="store.taskCompletions"
              @add="handleAddTask"
              @remove="store.removeTask"
            />
          </div>
          <div v-else key="rewards">
            <RewardTab 
              :rewards="store.rewards"
              :purchases="store.purchases"
              @add="handleAddReward"
              @remove="store.removeReward"
              @purchase="handlePurchaseReward"
            />
          </div>
        </Transition>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">

import { ref } from 'vue'
import { Calendar, ClipboardList, Gift } from 'lucide-vue-next'
import { usePladimStore } from '@/stores/pladim'
import type { Reward } from '@/types'

import HeaderUser from '@/components/layout/HeaderUser.vue'
import AgendaTab from '@/components/dashboard/AgendaTab.vue'
import TaskTab from '@/components/dashboard/TaskTab.vue'
import RewardTab from '@/components/dashboard/RewardTab.vue'

const store = usePladimStore()
const activeTab = ref<'agenda' | 'tasks' | 'rewards'>('agenda')

const tabs = [
  { id: 'agenda', label: 'Agenda', icon: Calendar },
  { id: 'tasks', label: 'Tarefas', icon: ClipboardList },
  { id: 'rewards', label: 'Recompensas', icon: Gift },
] as const

const handleLogout = () => {
  store.logout()
}

const handleResetData = () => {
  store.resetData()
}

const handleAddTask = ({ title, points, scheduledDays }: { title: string, points: number, scheduledDays: number[] }) => {
  store.addTask(title, points, scheduledDays)
}

const handleAddReward = ({ title, points }: { title: string, points: number }) => {
  store.addReward(title, points)
}

const handleToggleDate = ({ taskId, date }: { taskId: string, date: string }) => {
  store.toggleTaskDate(taskId, date)
}

const handlePurchaseReward = (reward: Reward) => {
  store.purchaseReward(reward)
}
</script>
