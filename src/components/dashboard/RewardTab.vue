<template>
  <div class="space-y-8">
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="p-6 bg-gray-50/50">
        <h3 class="text-lg font-semibold text-gray-800 flex items-center gap-2">
          <Plus class="w-5 h-5 text-teal-600" />
          Nova Recompensa
        </h3>
        <p class="text-sm text-gray-500 mt-1">Defina prêmios para se motivar a cumprir suas tarefas.</p>
      </div>
      <div class="h-px bg-gray-100 mx-6"></div>
      
      <div class="p-6 space-y-6">
        <div class="flex flex-col md:flex-row gap-4 items-start md:items-end">
          <div class="flex-1 space-y-3 w-full">
            <label class="text-xs font-semibold text-gray-500 uppercase tracking-wide ml-1">Nome</label>
            <input 
              v-model="newName" 
              type="text" 
              placeholder="Ex: Pizza"
              class="w-full px-4 py-2.5 rounded-xl border border-gray-200 bg-gray-50/30 focus:bg-white focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all placeholder:text-gray-400"
              @keyup.enter="addReward"
            >
          </div>
          
          <div class="w-full md:w-40 space-y-3">
            <label class="text-xs font-semibold text-gray-500 uppercase tracking-wide ml-1">Pontos</label>
            <input 
              v-model.number="newPoints" 
              type="number" 
              placeholder="100"
              class="w-full px-4 py-2.5 rounded-xl border border-gray-200 bg-gray-50/30 focus:bg-white focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-gray-700"
              @keyup.enter="addReward"
            >
          </div>

          <button 
            @click="addReward" 
            :disabled="!newName || newPoints <= 0"
            class="h-12 w-full md:w-12 bg-teal-600 text-white rounded-xl hover:bg-teal-700 hover:scale-105 active:scale-95 transition-all shadow-lg shadow-teal-600/20 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer disabled:shadow-none disabled:hover:scale-100 shrink-0"
            title="Adicionar Recompensa"
          >
            <Plus class="w-6 h-6 stroke-3" />
            <span class="md:hidden font-bold">Adicionar</span>
          </button>
        </div>
      </div>
    </div>

    <div class="space-y-4">
      <div class="flex items-center justify-between px-1">
        <h3 class="text-lg font-semibold text-gray-800">Recompensas Disponíveis</h3>
        <span class="text-sm text-gray-500 bg-gray-100 px-2 py-1 rounded-md">{{ rewards.length }} cadastradas</span>
      </div>

      <div v-if="rewards.length > 0" class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div 
          v-for="reward in rewards" 
          :key="reward.id" 
          class="bg-white p-5 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow group relative"
        >
          <div class="flex justify-between items-start mb-4 gap-3">
            <h4 class="font-medium text-gray-800 text-lg wrap-break-word flex-1">{{ reward.title }}</h4>
            <div class="flex items-center gap-2 shrink-0">
              <span class="px-3 py-1 bg-teal-50 text-teal-700 font-bold rounded-full text-sm border border-teal-100 whitespace-nowrap">
                {{ reward.points }} pts
              </span>
              <button 
                @click="$emit('remove', reward.id)" 
                class="p-1.5 text-gray-300 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors cursor-pointer"
                title="Excluir Recompensa"
              >
                <Trash2 class="w-4 h-4" />
              </button>
            </div>
          </div>
          
          <button 
            @click="$emit('purchase', reward)"
            class="w-full bg-teal-600 text-white py-2.5 rounded-lg font-medium hover:bg-teal-700 transition-all shadow-sm hover:shadow-md cursor-pointer flex items-center justify-center gap-2 mt-auto active:scale-[0.98]"
          >
            Resgatar
          </button>
        </div>
      </div>

      <div v-else class="text-center py-16 bg-white rounded-xl border border-dashed border-gray-300">
        <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-gray-50 mb-4">
          <Plus class="w-8 h-8 text-gray-300" />
        </div>
        <h3 class="text-lg font-medium text-gray-900">Nenhuma recompensa ainda</h3>
        <p class="mt-1 text-gray-500 max-w-sm mx-auto">Cadastre prêmios para você mesmo e troque seus pontos por eles!</p>
      </div>
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden mt-8">
      <div class="px-6 py-4 border-b border-gray-100 bg-gray-50 flex justify-between items-center">
        <h3 class="font-semibold text-gray-700">Histórico de Resgates</h3>
        <span class="text-xs text-gray-500">{{ purchases.length }} itens</span>
      </div>

      <div class="divide-y divide-gray-100 max-h-60 overflow-y-auto">
        <div v-for="purchase in sortedPurchases" :key="purchase.id" class="px-6 py-3 flex justify-between items-center hover:bg-gray-50/50">
          <div>
            <div class="font-medium text-gray-800">{{ purchase.rewardTitle }}</div>
            <div class="text-xs text-gray-400">{{ formatDate(purchase.purchasedAt) }}</div>
          </div>
          <div class="font-bold text-red-500 text-sm">
            -{{ purchase.cost }} pts
          </div>
        </div>
         <div v-if="purchases.length === 0" class="px-6 py-8 text-center text-gray-400 text-sm">
          Nenhum resgate realizado ainda.
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
import type { Reward, Purchase } from '@/types'

const props = defineProps<{
  rewards: Reward[]
  purchases: Purchase[]
}>()

const emit = defineEmits<{
  (e: 'add', payload: { title: string, points: number }): void
  (e: 'remove', id: string): void
  (e: 'purchase', reward: Reward): void
}>()

const newName = ref('')
const newPoints = ref(100)

const addReward = () => {
  if (newName.value && newPoints.value > 0) {
    emit('add', { title: newName.value, points: newPoints.value })
    newName.value = ''
    newPoints.value = 100
  }
}

const formatDate = (timestamp: number) => {
  return format(timestamp, "d 'de' MMM 'às' HH:mm", { locale: ptBR })
}

const sortedPurchases = computed(() => {
  return [...props.purchases].sort((a, b) => b.purchasedAt - a.purchasedAt)
})
</script>
