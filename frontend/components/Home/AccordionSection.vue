<template>
  <section>
    <BaseCard collapsable :default-collapsed="defaultCollapsed">
      <template #title>{{ title }}</template>
      <template #title-actions>
        <slot name="title-actions"></slot>
      </template>
      <div class="card-body pt-0">
        <slot></slot>
      </div>
    </BaseCard>
  </section>
</template>

<script setup lang="ts">
defineProps<{
  title: string;
  defaultCollapsed?: boolean;
}>();
</script>
