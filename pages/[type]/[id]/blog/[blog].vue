<template>
  <div class="card">
    <h1>{{ blog.title }}</h1>
    <p>{{ blog.description }}</p>
    <div class="info">
      <div class="created">
        <CalendarIcon /> {{ dayjs(blog.created).format('MMMM D, YYYY') }}
      </div>
    </div>
  </div>
  <div class="markdown-body card" v-html="renderHighlightedString(blog.content)" />
</template>
<script setup>
import dayjs from 'dayjs'
import {renderHighlightedString, CalendarIcon} from "omorphia";

const props = defineProps({
  project: {
    type: Object,
    default() {
      return {}
    },
  },
})

const route = useRoute()
const blog = ref({})

if (route.params.version === 'latest') {
  blog.value = props.project.blogs.reduce((a, b) => (a.created > b.created ? a : b))
} else {
  blog.value = props.project.blogs.find((x) => x.id === route.params.blog)
}

if (!blog.value) {
  throw createError({
    fatal: true,
    statusCode: 404,
    message: 'Blog not found',
  })
}

blog.value = JSON.parse(JSON.stringify(blog.value))

const title = computed(() => `${blog.value?.title} - ${props.project.title}`)
const description = computed(
  () => `${blog.value?.description}`
)

useSeoMeta({
  title,
  description,
  ogTitle: title,
  ogDescription: description,
})

</script>

<style lang="scss" scoped>
</style>
