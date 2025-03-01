<script setup lang="ts">
import type { ItemSummary } from "~~/lib/api/types/data-contracts";
import MdiLoading from "~icons/mdi/loading";
import MdiHeart from "~icons/mdi/heart";

definePageMeta({
  middleware: ["auth"],
});

useHead({
  title: "Homebox | Favorites",
});

const api = useUserApi();
const loading = useMinLoader(500);
const items = ref<ItemSummary[]>([]);
const total = ref(0);
const toast = useNotifier();

async function fetchFavorites() {
  loading.value = true;

  const { data, error } = await api.items.getFavorites();

  if (error) {
    loading.value = false;
    toast.error("Failed to get favorite items");
    return;
  }

  if (!data || data.length === 0) {
    loading.value = false;
    total.value = 0;
    items.value = [];
    return;
  }

  total.value = data.length;
  items.value = data;
  loading.value = false;
}

onMounted(fetchFavorites);
</script>

<template>
  <BaseContainer class="mb-16">
    <div class="flex items-center mb-6">
      <h1 class="text-2xl font-bold">
        <MdiHeart class="inline-block mr-2 text-red-500" /> Favorite Items
      </h1>
      <button class="btn btn-sm ml-auto" @click="fetchFavorites">
        <MdiLoading v-if="loading" class="animate-spin" />
        <span v-else>Refresh</span>
      </button>
    </div>

    <section>
      <p class="text-base font-medium flex items-center mb-4">
        {{ total }} Favorite Items
      </p>

      <div v-if="loading" class="flex justify-center my-10">
        <MdiLoading class="animate-spin h-10 w-10" />
      </div>

      <div v-else-if="items.length === 0" class="text-center my-10">
        <p class="text-lg">No favorite items found</p>
        <p class="text-sm text-gray-500 mt-2">
          Mark items as favorites by clicking the heart icon on an item's detail page
        </p>
        <NuxtLink to="/items" class="btn btn-primary mt-4">Browse Items</NuxtLink>
      </div>

      <div v-else class="grid mt-4 grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
        <ItemCard v-for="item in items" :key="item.id" :item="item" />
      </div>
    </section>
  </BaseContainer>
</template>
