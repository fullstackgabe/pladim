<template>
  <div class="space-y-8">
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="p-6 bg-gray-50/50">
        <h3 class="text-lg font-semibold text-gray-800 flex items-center gap-2">
          <Plus class="w-5 h-5 text-teal-600" />
          Nova Tarefa
        </h3>
        <p class="text-sm text-gray-500 mt-1">Crie hábitos e tarefas recorrentes para ganhar pontos.</p>
      </div>
      <div class="h-px bg-gray-100 mx-6"></div>
      
      <div class="p-6 space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-12 gap-4">
          <div class="md:col-span-8 space-y-3">
            <label class="text-xs font-semibold text-gray-500 uppercase tracking-wide ml-1">Nome da Tarefa</label>
            <input 
              v-model="newName" 
              type="text" 
              placeholder="Ex: Academia"
              class="w-full px-4 py-2.5 rounded-xl border border-gray-200 bg-gray-50/30 focus:bg-white focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all placeholder:text-gray-400"
            >
          </div>
          
          <div class="md:col-span-4 space-y-3">
            <label class="text-xs font-semibold text-gray-500 uppercase tracking-wide ml-1">Pontos</label>
            <div class="relative">
              <input 
                v-model.number="newPoints" 
                type="number" 
                placeholder="100"
                class="w-full px-4 py-2.5 rounded-xl border border-gray-200 bg-gray-50/30 focus:bg-white focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-gray-700"
              >
            </div>
          </div>
        </div>
        
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-6 pt-2">
          <div class="space-y-3 w-full md:w-auto">
            <label class="text-xs font-semibold text-gray-500 uppercase tracking-wide ml-1">Frequência</label>
            <div class="flex justify-between md:justify-start gap-1 sm:gap-2">
              <button
                v-for="(day, index) in weekDays"
                :key="index"
                @click="toggleDaySelection(index)"
                class="h-8 w-8 sm:h-9 sm:w-9 rounded-full text-[10px] sm:text-xs font-bold transition-all border cursor-pointer flex items-center justify-center"
                :class="newScheduledDays.includes(index) 
                  ? 'bg-teal-600 text-white border-teal-600 shadow-sm ring-2 ring-teal-100 scale-105' 
                  : 'bg-white text-gray-400 border-gray-200 hover:border-teal-300 hover:bg-teal-50 hover:text-teal-600'"
              >
                {{ day.charAt(0) }}
              </button>
            </div>
          </div>

          <button 
            @click="addTask" 
            :disabled="!newName || newPoints <= 0 || newScheduledDays.length === 0"
            class="h-12 w-full md:w-12 bg-teal-600 text-white rounded-xl hover:bg-teal-700 hover:scale-105 active:scale-95 transition-all shadow-lg shadow-teal-600/20 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer disabled:shadow-none disabled:hover:scale-100 md:self-auto"
            title="Adicionar Tarefa"
          >
            <Plus class="w-6 h-6 stroke-3" />
            <span class="md:hidden font-bold">Adicionar Tarefa</span>
          </button>
        </div>
      </div>
    </div>

    <div class="space-y-4">
      <div class="flex items-center justify-between px-1">
        <h3 class="text-lg font-semibold text-gray-800">Suas Tarefas</h3>
        <span class="text-sm text-gray-500 bg-gray-100 px-2 py-1 rounded-md">{{ tasks.length }} cadastradas</span>
      </div>

      <div v-if="tasks.length > 0" class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div 
          v-for="task in tasks" 
          :key="task.id" 
          class="bg-white p-5 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow group"
        >
          <div class="flex justify-between items-start mb-3 gap-3">
            <h4 class="font-medium text-gray-800 text-lg wrap-break-word flex-1">{{ task.title }}</h4>
            <div class="flex items-center gap-2 shrink-0">
              <span class="px-3 py-1 bg-teal-50 text-teal-700 font-bold rounded-full text-sm border border-teal-100 whitespace-nowrap">
                +{{ task.points }} pts
              </span>
              <button 
                @click="$emit('remove', task.id)" 
                class="p-1.5 text-gray-300 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors cursor-pointer"
                title="Excluir Tarefa"
              >
                <Trash2 class="w-4 h-4" />
              </button>
            </div>
          </div>
          
          <div class="flex items-center gap-2 text-sm text-gray-500">
            {{ formatScheduledDays(task.scheduledDays) }}
          </div>
        </div>
      </div>

      <div v-else class="text-center py-16 bg-white rounded-xl border border-dashed border-gray-300">
        <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-gray-50 mb-4">
          <Plus class="w-8 h-8 text-gray-300" />
        </div>
        <h3 class="text-lg font-medium text-gray-900">Nenhuma tarefa ainda</h3>
        <p class="mt-1 text-gray-500 max-w-sm mx-auto">Comece adicionando tarefas que você deseja realizar regularmente para acumular pontos.</p>
      </div>
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden mt-8">
      <div class="px-6 py-4 border-b border-gray-100 bg-gray-50 flex justify-between items-center">
        <h3 class="font-semibold text-gray-700">Histórico de Tarefas</h3>
        <span class="text-xs text-gray-500">{{ taskCompletions.length }} itens</span>
      </div>
      <div class="divide-y divide-gray-100 max-h-60 overflow-y-auto">
        <div v-for="item in sortedCompletions" :key="item.id" class="px-6 py-3 flex justify-between items-center hover:bg-gray-50/50">
          <div>
            <div class="font-medium text-gray-800">{{ item.taskTitle }}</div>
            <div class="text-xs text-gray-400">{{ formatDate(item.completedAt) }}</div>
          </div>
          <div class="font-bold text-teal-600 text-sm whitespace-nowrap">+{{ item.points }} pts</div>
        </div>
        <div v-if="taskCompletions.length === 0" class="px-6 py-8 text-center text-gray-400 text-sm">
          Nenhuma tarefa concluída ainda.
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { Plus, Trash2 } from 'lucide-vue-next'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import type { Task, TaskCompletion } from '@/types'

const props = defineProps<{
  tasks: Task[]
  taskCompletions: TaskCompletion[]
}>()

const emit = defineEmits<{
  (e: 'add', payload: { title: string, points: number, scheduledDays: number[] }): void
  (e: 'remove', id: string): void
}>()

const newName = ref('')
const newPoints = ref(100)
const newScheduledDays = ref<number[]>([1, 2, 3, 4, 5]) 
const weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']

const toggleDaySelection = (dayIndex: number) => {
  const index = newScheduledDays.value.indexOf(dayIndex)
  if (index === -1) {
    newScheduledDays.value.push(dayIndex)
    newScheduledDays.value.sort((a, b) => a - b)
  } else {
    newScheduledDays.value.splice(index, 1)
  }
}

const addTask = () => {
  if (newName.value && newPoints.value > 0 && newScheduledDays.value.length > 0) {
    emit('add', { 
      title: newName.value, 
      points: newPoints.value,
      scheduledDays: [...newScheduledDays.value]
    })
    
    newName.value = ''
    newPoints.value = 100
  }
}

const formatDate = (timestamp: number) => {
  return format(timestamp, "d 'de' MMM 'às' HH:mm", { locale: ptBR })
}

const sortedCompletions = computed(() =>
  [...props.taskCompletions].sort((a, b) => b.completedAt - a.completedAt)
)

const formatScheduledDays = (days: number[] | undefined) => {
  if (!days || days.length === 7) return 'Todos os dias'
  if (days.length === 0) return 'Nenhum dia'
  
  const sortedDays = [...days].sort((a, b) => a - b)
  
  const isWeekDaysOnly = sortedDays.length === 5 && !sortedDays.includes(0) && !sortedDays.includes(6)
  if (isWeekDaysOnly) return 'Dias úteis'
  
  const isWeekendOnly = sortedDays.length === 2 && sortedDays.includes(0) && sortedDays.includes(6)
  if (isWeekendOnly) return 'Fim de semana'
  
  return sortedDays.map(d => weekDays[d]).join(', ')
}
</script>
