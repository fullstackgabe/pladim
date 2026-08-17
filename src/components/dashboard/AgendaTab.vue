<template>
  <div class="space-y-6">
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="p-6 bg-linear-to-b from-white to-gray-50/50">
        <div class="flex items-center justify-between mb-6">
          <h2 class="text-xl font-bold text-gray-800 capitalize tracking-tight w-full text-center">
            {{ formattedMonth }}
          </h2>
        </div>

        <div class="grid grid-cols-7 mb-3">
          <div v-for="day in weekDays" :key="day" class="text-center text-[10px] font-bold text-gray-700 uppercase tracking-wider py-2">
            {{ day }}
          </div>
        </div>
        <div class="grid grid-cols-7 gap-y-2 gap-x-1">
          <button
            v-for="date in calendarDays"
            :key="date.toISOString()"
            @click="isCurrentWeek(date) ? selectDate(date) : null"
            class="h-10 w-10 mx-auto flex items-center justify-center rounded-full text-sm transition-all relative group"
            :class="getDayClasses(date)"
          >
            {{ format(date, 'd') }}
            
            <div 
              v-if="hasTasksForDate(date) && isCurrentWeek(date)" 
              class="absolute bottom-1.5 w-1 h-1 rounded-full transition-colors" 
              :class="isSameDay(date, selectedDate) ? 'bg-white' : 'bg-teal-400 group-hover:bg-teal-500'"
            ></div>
          </button>
        </div>
      </div>
      <div class="h-2 bg-linear-to-b from-white to-gray-50/50"></div>
    </div>

    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="p-5 bg-gray-50/30 flex justify-between items-center">
        <h3 class="font-bold text-gray-800 capitalize flex items-center gap-2">
          <span class="w-1.5 h-1.5 rounded-full bg-teal-500"></span>
          {{ formattedSelectedDate }}
        </h3>
        <span class="text-xs font-semibold text-gray-500 bg-white px-2.5 py-1 rounded-lg border border-gray-100 shadow-sm whitespace-nowrap">
          {{ agendaItems.length }} tarefas
        </span>
      </div>
      <div class="h-px bg-gray-100 mx-6"></div>
      
      <div v-if="agendaItems.length === 0" class="flex flex-col items-center justify-center py-6 text-center">
        <div class="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center mb-2">
          <CheckCircle class="w-5 h-5 text-gray-300" />
        </div>
        <p class="text-gray-400 font-medium">Nenhuma tarefa para hoje</p>
        <p class="text-xs text-gray-400 mt-1">Aproveite o descanso!</p>
      </div>

      <div v-else class="divide-y divide-gray-50">
        <div
          v-for="item in agendaItems"
          :key="item.key"
          class="p-4 flex items-center justify-between transition-all hover:bg-gray-50 group"
        >
          <div class="flex items-center gap-4">
            <button
              @click="toggleTask(item.taskId)"
              class="transition-all focus:outline-none text-gray-300 hover:text-teal-500 cursor-pointer transform hover:scale-110 active:scale-95"
              :class="item.completed ? 'text-teal-500' : ''"
            >
              <CheckCircle v-if="item.completed" class="w-6 h-6 fill-teal-50" />
              <Circle v-else class="w-6 h-6 stroke-2" />
            </button>
            <div class="flex flex-col">
              <span
                class="font-medium transition-all"
                :class="item.completed ? 'text-gray-400 line-through decoration-gray-300' : 'text-gray-700'"
              >
                {{ item.title }}
              </span>
            </div>
          </div>
          <div class="flex items-center gap-2">
            <span
              class="text-xs font-bold px-2.5 py-1 rounded-full border transition-all"
              :class="item.completed
                ? 'bg-gray-100 text-gray-400 border-gray-100'
                : 'bg-teal-50 text-teal-700 border-teal-100'"
            >
              +{{ item.points }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { 
  format, 
  startOfWeek, 
  endOfWeek, 
  startOfMonth,
  endOfMonth,
  eachDayOfInterval, 
  isSameDay, 
  isSameWeek,
  isToday, 
  getDay
} from 'date-fns'
import { ptBR } from 'date-fns/locale'
import { CheckCircle, Circle } from 'lucide-vue-next'
import type { Task, TaskCompletion } from '@/types'

const props = defineProps<{
  tasks: Task[]
  taskCompletions: TaskCompletion[]
}>()

const emit = defineEmits<{
  (e: 'toggle-date', payload: { taskId: string, date: string }): void
}>()

const currentDate = ref(new Date())
const selectedDate = ref(new Date())
const weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']

const formattedMonth = computed(() => {
  return format(currentDate.value, 'MMMM yyyy', { locale: ptBR })
})

const formattedSelectedDate = computed(() => {
  return format(selectedDate.value, "EEEE, dd/MM", { locale: ptBR })
})

const calendarDays = computed(() => {
  const start = startOfWeek(startOfMonth(currentDate.value), { weekStartsOn: 0 })
  const end = endOfWeek(endOfMonth(currentDate.value), { weekStartsOn: 0 })
  return eachDayOfInterval({ start, end })
})

type AgendaItem = {
  key: string
  taskId: string
  title: string
  points: number
  completed: boolean
}

const orphanCompletionsForDate = (dateStr: string) => {
  const activeTaskIds = new Set(props.tasks.map(t => t.id))
  return props.taskCompletions.filter(c => c.completedDate === dateStr && !activeTaskIds.has(c.taskId))
}

const agendaItems = computed<AgendaItem[]>(() => {
  const dayOfWeek = getDay(selectedDate.value)
  const dateStr = format(selectedDate.value, 'yyyy-MM-dd')

  const activeItems: AgendaItem[] = props.tasks
    .filter(task => task.scheduledDays.includes(dayOfWeek))
    .map(task => ({
      key: task.id,
      taskId: task.id,
      title: task.title,
      points: task.points,
      completed: task.completedDates.includes(dateStr),
    }))

  const orphanItems: AgendaItem[] = orphanCompletionsForDate(dateStr).map(c => ({
    key: `orphan-${c.id}`,
    taskId: c.taskId,
    title: c.taskTitle,
    points: c.points,
    completed: true,
  }))

  return [...activeItems, ...orphanItems]
})

const isCurrentWeek = (date: Date) => {
  return isSameWeek(date, currentDate.value, { weekStartsOn: 0 })
}

const selectDate = (date: Date) => {
  selectedDate.value = date
}

const hasTasksForDate = (date: Date) => {
    const dayOfWeek = getDay(date)
    const dateStr = format(date, 'yyyy-MM-dd')
    if (props.tasks.some(task => task.scheduledDays.includes(dayOfWeek))) return true
    return orphanCompletionsForDate(dateStr).length > 0
}

const toggleTask = (taskId: string) => {
  const dateStr = format(selectedDate.value, 'yyyy-MM-dd')
  emit('toggle-date', { taskId, date: dateStr })
}

const getDayClasses = (date: Date) => {
  const isCurrent = isCurrentWeek(date)
  const isSelected = isSameDay(date, selectedDate.value)
  const isTodayDate = isToday(date)

  if (!isCurrent) {
    return 'text-gray-400 cursor-default opacity-50'
  }

  if (isSelected) {
    return 'bg-teal-600 text-white font-bold shadow-md shadow-teal-600/20 scale-105 cursor-pointer'
  }

  const baseClasses = 'text-gray-700 hover:bg-teal-50 hover:text-teal-600 cursor-pointer'
  
  if (isTodayDate) {
    return `${baseClasses} ring-2 ring-teal-100 text-teal-700 font-bold`
  }

  return baseClasses
}
</script>
