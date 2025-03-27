<template>
  <div v-if="version" class="version-page">
    <div class="version-page__title card">
      <Breadcrumbs
        :current-title="version.name"
        :link-stack="[
          {
            href: getPreviousLink,
            label: 'Versions',
          },
        ]"
      />
      <div class="version-header">
        <h2>{{ version.name }}</h2>
      </div>
      <div class="input-group">
        <a
          v-if="primaryFile"
          v-tooltip="primaryFile.filename + ' (' + formatBytes(primaryFile.size) + ')'"
          :href="primaryFile.url"
          class="btn btn-primary"
          :aria-label="`Download ${primaryFile.filename}`"
        >
          <DownloadIcon aria-hidden="true"/>
          Download
        </a>
      </div>
    </div>
    <div class="version-page__maven card" v-if="cosmetics.mavenInfo">
      <h3>Maven Usage</h3>
      <MavenInfo :group="project.group" :artifact="version.artifact" :version="version.version"/>
    </div>
    <div
      v-if="deps.length > 0"
      class="version-page__dependencies card"
    >
      <h3>Dependencies</h3>
      <a
        v-for="(dependency, index) in deps.filter((x) => !x.file_name)"
        :key="index"
        class="dependency button-base button-transparent"
        :href="dependency.link" :target="external()"
      >
        <Avatar
          :src="null"
          alt="dependency-icon"
          size="sm"
        />
        <div class="info">
          <span class="project-title">
            {{ dependency.name }}
          </span>
          <span class="dep-type">{{ dependency.dependency_type }}</span>
        </div>
      </a>
    </div>
    <div class="version-page__files card">
      <h3>Files</h3>
      <div
        v-for="(file) in version.files"
        :key="file.hashes.sha1"
        :class="{
          file: true,
          primary: primaryFile.hashes.sha1 === file.hashes.sha1,
        }"
      >
        <FileIcon/>
        <span class="filename">
          <strong>{{ file.filename }}</strong>
          <span class="file-size">({{ formatBytes(file.size) }})</span>
          <span v-if="primaryFile.hashes.sha1 === file.hashes.sha1" class="file-type">
            Primary
          </span>
          <span
            v-else-if="file.file_type === 'required-resource-pack'"
            class="file-type"
          >
            Required resource pack
          </span>
          <span
            v-else-if="file.file_type === 'optional-resource-pack'"
            class="file-type"
          >
            Optional resource pack
          </span>
        </span>
        <a
          :href="file.url"
          class="btn raised"
          :title="`Download ${file.filename}`"
          tabindex="0"
        >
          <DownloadIcon/>
          Download
        </a>
      </div>
    </div>
    <div class="version-page__metadata">
      <div class="card full-width-inputs">
        <h3>About</h3>
        <div>
          <h4>Release channel</h4>
          <Badge
            v-if="version.version_type === 'release'"
            class="value"
            type="release"
            color="green"
          />
          <Badge
            v-else-if="version.version_type === 'beta'"
            class="value"
            type="beta"
            color="orange"
          />
          <Badge
            v-else-if="version.version_type === 'alpha'"
            class="value"
            type="alpha"
            color="red"
          />
        </div>
        <div>
          <h4>Version number</h4>
          <span>{{ version.version_number }}</span>
        </div>
        <div v-if="project.project_type !== 'resourcepack'">
          <h4>Loaders</h4>
          <Categories :categories="version.loaders" :type="project.actualProjectType"/>
        </div>
        <div>
          <h4>Game versions</h4>
          <span>{{ formatVersions(version.game_versions, tags.gameVersions) }}</span>
        </div>
        <div>
          <h4>Size</h4>
          <span>{{ formatBytes(version.primaryFile.size) }}</span>
        </div>
        <div>
          <h4>Publication date</h4>
          <span>
            {{ dayjs(version.date_published).format('MMMM D, YYYY [at] h:mm A') }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
import dayjs from 'dayjs'
import {
  Avatar,
  Badge,
  Breadcrumbs,
  Categories,
  DownloadIcon,
  FileIcon,
  formatBytes,
  formatVersions,
} from 'omorphia'
import MavenInfo from "~/components/ui/MavenInfo.vue";

const props = defineProps({
  project: {
    type: Object,
    default() {
      return {}
    },
  },
  versions: {
    type: Array,
    default() {
      return []
    },
  },
  dependencies: {
    type: Object,
    default() {
      return {}
    },
  },
})

const route = useRoute()
const cosmetics = useCosmetics()

const tags = useTags()

const fileTypes = ref([
  {
    display: 'Required resource pack',
    value: 'required-resource-pack',
  },
  {
    display: 'Optional resource pack',
    value: 'optional-resource-pack',
  },
])
const oldFileTypes = ref([])

const version = ref({})
const primaryFile = ref({})
const alternateFile = ref({})

if (route.params.version === 'latest') {
  let versionList = JSON.parse(JSON.stringify(props.versions))
  if (route.query.loader) {
    versionList = versionList.filter((x) => x.loaders.includes(route.query.loader))
  }
  if (route.query.version) {
    versionList = versionList.filter((x) => x.game_versions.includes(route.query.version))
  }
  version.value = versionList.reduce((a, b) => (a.date_published > b.date_published ? a : b))
} else {
  version.value = props.versions.find((x) => x.id === route.params.version)

  if (!version.value) {
    version.value = props.versions.find((x) => x.displayUrlEnding === route.params.version)
  }
}

if (!version.value) {
  throw createError({
    fatal: true,
    statusCode: 404,
    message: 'Version not found',
  })
}

version.value = JSON.parse(JSON.stringify(version.value))
primaryFile.value = version.value.files.find((file) => file.primary) ?? version.value.files[0]
alternateFile.value = version.value.files.find(
  (file) => file.file_type && file.file_type.includes('resource-pack')
)

oldFileTypes.value = version.value.files.map((x) =>
  fileTypes.value.find((y) => y.value === x.file_type)
)

const title = computed(() => `${version.value?.name} - ${props.project.title}`)
const description = computed(
  () =>
    `Download ${props.project.title} ${
      version.value.version_number
    } on Beehive. Supports ${formatVersions(
      version.value.game_versions,
      tags.value.gameVersions
    )} ${version.value.loaders
      .map((x) => x.charAt(0).toUpperCase() + x.slice(1))
      .join(' & ')}. Published on ${dayjs(version.value.date_published).format('MMM D, YYYY')}. ${
      version.value.downloads
    } downloads.`
)

useSeoMeta({
  title,
  description,
  ogTitle: title,
  ogDescription: description,
})

const deps = computed(() => {
  const order = ['required', 'optional', 'incompatible', 'embedded']
  return [...version.value.dependencies].sort(
    (a, b) => order.indexOf(a.dependency_type) - order.indexOf(b.dependency_type)
  )
})

const getPreviousLink = computed(() => {
  const router = useRouter()
  if (router.options.history.state.back) {
    if (router.options.history.state.back.includes('/versions')) {
      return router.options.history.state.back
    }
  }
  return `/${props.project.project_type}/${route.params.id}/versions`
})

</script>

<style lang="scss" scoped>
.changelog-editor-spacing {
  padding-block: var(--gap-md);
}

.version-page {
  display: grid;

  grid-template:
    'title' auto
    'maven' auto
    'dependencies' auto
    'metadata' auto
    'files' auto
    / 1fr;

  column-gap: var(--gap-md);

  .version-page__title {
    grid-area: title;

    .version-header {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      margin-bottom: 1rem;
      gap: var(--gap-md);

      h2,
      input[type='text'] {
        margin: 0;
        font-size: var(--font-size-2xl);
        font-weight: bold;
      }

      input[type='text'] {
        max-width: 100%;
        min-width: 0;
        flex-grow: 1;
        width: 2rem;
      }

      .featured {
        display: flex;
        align-items: center;
        gap: var(--gap-xs);

        svg {
          height: 1.45rem;
        }
      }
    }

    .known-errors {
      margin-bottom: 1rem;
    }
  }

  h3 {
    font-size: var(--font-size-lg);
    margin: 0 0 0.5rem 0;
  }

  .version-page__maven {
    grid-area: maven;
    overflow-x: hidden;
  }

  .version-page__dependencies {
    grid-area: dependencies;

    .dependency {
      align-items: center;
      display: flex;
      gap: var(--gap-sm);
      padding: var(--gap-sm);

      .info {
        display: flex;
        flex-direction: column;
        gap: var(--gap-xs);

        .project-title {
          font-weight: bold;
        }

        .dep-type {
          color: var(--color-secondary);

          &.incompatible {
            color: var(--color-red);
          }

          &::first-letter {
            text-transform: capitalize;
          }
        }
      }

      button {
        margin-left: auto;
      }
    }

    .add-dependency {
      h4 {
        margin-bottom: var(--gap-sm);
      }

      .input-group {
        &:not(:last-child) {
          margin-bottom: var(--gap-sm);
        }

        .multiselect {
          width: 8rem;
          flex-grow: 1;
        }

        input {
          flex-grow: 2;
        }
      }
    }
  }

  .version-page__files {
    grid-area: files;

    .file {
      --text-color: var(--color-contrast);
      --background-color: var(--color-button-bg);

      &.primary {
        --background-color: var(--color-brand-highlight);
        --text-color: var(--color-contrast);
      }

      display: flex;
      align-items: center;

      font-weight: 500;
      color: var(--text-color);
      background-color: var(--background-color);
      padding: var(--gap-sm) var(--gap-lg);
      border-radius: var(--radius-sm);

      svg {
        min-width: 1.1rem;
        min-height: 1.1rem;
        margin-right: 0.5rem;
      }

      .filename {
        word-wrap: anywhere;
      }

      .file-size {
        margin-left: 1ch;
        font-weight: 400;
        white-space: nowrap;
      }

      .file-type {
        margin-left: 1ch;
        font-style: italic;
        font-weight: 300;
      }

      .raised-multiselect {
        display: none;
        margin: 0 0.5rem;
        height: 40px;
        max-height: 40px;
        min-width: 235px;
      }

      .btn {
        margin-left: auto;
      }

      &:not(:nth-child(2)) {
        margin-top: 0.5rem;
      }

      // TODO: Make file type editing  work on mobile
      @media (min-width: 600px) {
        .raised-multiselect {
          display: block;
        }
      }
    }

    .additional-files {
      h4 {
        margin-bottom: 0.5rem;
      }

      label {
        margin-top: 0.5rem;
      }
    }
  }

  .version-page__metadata {
    grid-area: metadata;

    h4 {
      margin: 1rem 0 0.25rem 0;
    }
  }
}

@media (min-width: 1200px) {
  .version-page {
    grid-template:
      'title title' auto
      'maven maven' auto
      'dependencies metadata' auto
      'files metadata' auto
      'dummy metadata' 1fr
      / 1fr 20rem;
  }
}

.separator {
  margin: var(--gap-sm) 0;
}

.modal-package-mod {
  padding: var(--gap-lg);
  display: flex;
  flex-direction: column;

  .markdown-body {
    margin-bottom: 1rem;
  }

  .multiselect {
    max-width: 20rem;
  }
}
</style>
