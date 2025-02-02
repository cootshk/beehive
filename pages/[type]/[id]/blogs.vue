<template>
  <div>
    <div class="items">
      <nuxt-link v-for="(item, index) in project.blogs" :key="index" class="card item" :to="`/${project.project_type}/${route.params.id}/blog/${item.id}`">
        <div class="body">
          <div class="info">
            <h2>{{ item.title }}</h2>
            <p>{{ item.description }}</p>
          </div>
          <div class="created">
            <CalendarIcon/>
            {{ dayjs(item.created).format('MMMM D, YYYY') }}
          </div>
        </div>
        <img
          class="image"
          :src="item.image"
          :alt="item.title || 'image'"
        />
      </nuxt-link>
    </div>
  </div>
</template>

<script setup>
import dayjs from 'dayjs'
import { CalendarIcon } from 'omorphia'

const route = useRoute()

const props = defineProps({
  project: {
    type: Object,
    default() {
      return {}
    },
  },
})

const title = `${props.project.title} - Blogs`
const description = `View ${props.project.gallery.length} blogs for ${props.project.title} on Beehive.`

useSeoMeta({
  title,
  description,
  ogTitle: title,
  ogDescription: description,
})
</script>

<style lang="scss" scoped>
.items {
  display: grid;
  grid-template-rows: 1fr;
  grid-template-columns: 1fr;
  grid-gap: var(--gap-sm);
}

.item {
  display: grid;
  grid-template-columns: 2fr 1fr;
  padding: 0;

  cursor: pointer;

  img {
    width: 100%;
    margin-top: 0;
    margin-bottom: 0;
    border-radius: 0 8px 8px 0;

    min-height: 10rem;
    object-fit: cover;
  }

  .body {
    display: flex;
    flex-direction: column;
    flex-grow: 1;
    justify-content: space-between;

    width: calc(100% - 2 * var(--gap-md));
    padding: var(--gap-md);

    .info {
      h2 {
        margin-bottom: 0.5rem;
      }

      p {
        margin: 0 0 0.5rem 0;
      }
    }
  }

  .bottom {
    width: calc(100% - 2 * var(--gap-md));
    padding: 0 var(--gap-md) var(--gap-sm) var(--gap-md);

    .created {
      display: flex;
      align-items: center;
      margin-bottom: 0.5rem;
      color: var(--color-secondary);

      svg {
        width: 1rem;
        height: 1rem;
        margin-right: 0.25rem;
      }
    }

    .columns {
      margin-bottom: 0.5rem;
    }
  }
}
</style>
