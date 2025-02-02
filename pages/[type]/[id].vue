<template>
  <div :style="`--_accent-color: ${toColor(project.color)}`">
    <ShareModal
      ref="modalShare"
      :share-title="project.title"
      :share-text="`${config.public.siteUrl}/${project.project_type}/${route.params.id}`"
      link
    />
    <Modal ref="downloadModal" :header="`Download ${project.title}`">
      <div class="download-modal-content">
        <div v-if="selectingGameVersion" class="list-selection-page">
          <div class="heading">
            <h2>Select game version</h2>
            <button class="btn" @click="() => (selectingGameVersion = false)">
              <LeftArrowIcon /> Back
            </button>
          </div>
          <ScrollableMultiSelect>
            <ListSelector
              v-for="{ version, valid } in gameVersionSuggestions.filter(
                (x) => !gameVersionQuery || x.version.includes(gameVersionQuery)
              )"
              :key="version"
              v-tooltip="
                !valid
                  ? `${project.title} is not available for ${formatCategory(
                      selectedPlatform
                    )} on ${version}`
                  : null
              "
              :class="{
                incompatible: !valid,
              }"
              :model-value="selectedGameVersion === version"
              class="list-selector"
              @click="
                () => {
                  selectedGameVersion = version
                  selectingGameVersion = false

                  if (!valid) {
                    selectedPlatform = null
                    highlightPlatform = true
                  }
                }
              "
            >
              {{ version }}
            </ListSelector>
          </ScrollableMultiSelect>
          <div class="toggle-option">
            <label for="show-all-versions"> Show snapshot versions </label>
            <Toggle id="show-all-versions" v-model="showSnapshots" :checked="showSnapshots" />
          </div>
        </div>
        <div v-else-if="selectingPlatform" class="list-selection-page">
          <div class="heading">
            <h2>Select platform</h2>
            <button class="btn" @click="() => (selectingPlatform = false)">
              <LeftArrowIcon />
              Back
            </button>
          </div>
          <ScrollableMultiSelect>
            <ListSelector
              v-for="{ platform, valid } in platformSuggestions"
              :key="platform"
              v-tooltip="
                !valid
                  ? `${project.title} is not available for ${formatCategory(
                      platform
                    )} on ${selectedGameVersion}`
                  : null
              "
              :class="{
                incompatible: !valid,
              }"
              class="list-selector"
              :model-value="selectedPlatform === platform"
              @click="
                () => {
                  selectedPlatform = platform
                  selectingPlatform = false

                  if (!valid) {
                    selectedGameVersion = null
                    highlightGameVersion = true
                  }
                }
              "
            >
              {{ formatCategory(platform) }}
            </ListSelector>
          </ScrollableMultiSelect>
        </div>
        <div v-else class="main-page">
          <div class="input-group">
            <button
              class="btn"
              :disabled="project.game_versions.length === 1"
              :class="{ 'warning-outline': highlightGameVersion && !selectedGameVersion }"
              @click="() => (selectingGameVersion = true)"
            >
              <GameIcon />

              {{
                project.game_versions.length === 1
                  ? `Game version: ${project.game_versions[0]}`
                  : selectedGameVersion
                  ? `Game version: ${selectedGameVersion}`
                  : 'Select game version'
              }}
              <ChevronRightIcon />
            </button>
            <UnknownIcon
              v-if="project.game_versions.length === 1"
              v-tooltip="
                `${project.title} is only available for ${formatCategory(project.game_versions[0])}`
              "
              class="help-icon"
            />
          </div>
          <div class="input-group">
            <button
              class="btn"
              :disabled="project.loaders.length === 1"
              :class="{ 'warning-outline': highlightPlatform && !selectedPlatform }"
              @click="() => (selectingPlatform = true)"
            >
              <WrenchIcon />
              {{
                project.loaders.length === 1
                  ? `Platform: ${formatCategory(project.loaders[0])}`
                  : selectedPlatform
                  ? `Platform: ${formatCategory(selectedPlatform)}`
                  : 'Select platform'
              }}
              <ChevronRightIcon />
            </button>
            <UnknownIcon
              v-if="project.loaders.length === 1"
              v-tooltip="
                `${project.title} is only available for ${formatCategory(project.loaders[0])}`
              "
              class="help-icon"
            />
          </div>
          <Button
            color="primary"
            large
            :link="selectedVersion ? selectedVersion.primaryFile.url : ''"
            :disabled="!selectedVersion"
          >
            <DownloadIcon />
            Download
          </Button>
        </div>
      </div>
    </Modal>
    <div class="normal-page">
      <div class="normal-page__header">
        <div class="breadcrumbs">
          <nuxt-link :to="`/projects`">Minecraft: Java Edition</nuxt-link>
          <ChevronRightIcon />
          <nuxt-link :to="`/projects`">Projects</nuxt-link>
          <ChevronRightIcon />
          <span class="current">{{ project.title }}</span>
        </div>
        <div class="proj-header">
          <div class="game-icon">
            <Avatar :src="project.icon_url" class="avatar" no-shadow size="none" />
          </div>
          <div class="game-title">
            <div class="game-name">
              <h1>{{ project.title }}</h1>
            </div>
            <div class="mod-stats">
              <span class="stat">
                <span class="label"><DownloadIcon /></span>
                <span class="value">{{ formatNumber(project.downloads) }}</span>
                <span class="label"> downloads</span>
              </span>
              <span class="stat">
                <span class="label"><HeartIcon /></span>
                <span class="value">{{ formatNumber(project.followers) }}</span>
                <span class="label"> followers</span>
              </span>
              <span class="stat">
                <span class="label"><UpdatedIcon /></span>
                <span class="label">Updated</span>
                <span class="value">{{ fromNow(project.updated) }}</span>
              </span>
            </div>
          </div>
          <div class="mod-buttons">
            <div class="joined-buttons">
              <Button
                color="primary"
                large
                @click="
                  () => {
                    downloadModal.show()
                    selectedGameVersion = null
                    selectedPlatform = null
                  }
                "
              >
                <DownloadIcon />
                Download Latest
              </Button>
            </div>
          </div>
        </div>
        <PageBar class="filter-row">
          <nuxt-link
            :to="`/${project.project_type}/${route.params.id}`"
            class="button-base nav-button"
          >
            <DescriptionIcon />
            About
          </nuxt-link>
          <nuxt-link
            v-if="project.gallery.length > 0"
            :to="`/${project.project_type}/${route.params.id}/gallery`"
            class="button-base nav-button"
          >
            <GalleryIcon />
            Gallery
          </nuxt-link>
          <nuxt-link
            v-if="project.blogs.length > 0"
            :to="`/${project.project_type}/${route.params.id}/blogs`"
            class="button-base nav-button"
          >
            <GalleryIcon />
            Blogs
          </nuxt-link>
          <nuxt-link
            :to="`/${project.project_type}/${route.params.id}/versions`"
            class="button-base nav-button"
          >
            <VersionIcon />
            Versions
          </nuxt-link>
        </PageBar>
      </div>
      <section class="normal-page__content">
        <NuxtPage
          v-model:project="project"
          v-model:versions="versions"
          v-model:all-members="allMembers"
        />
      </section>
      <div class="normal-page__info">
        <nuxt-link
          v-if="featuredGalleryImage"
          :to="`${getProjectLink(project)}/gallery`"
          class="featured-gallery-image button-base"
        >
          <img
            :src="featuredGalleryImage.url"
            alt="test"
          />
        </nuxt-link>
        <div class="card">
          <h2>Details</h2>
          <div class="supports-details">
            <div class="primary-stat">
              <GameIcon class="primary-stat__icon" aria-hidden="true" />
              <div class="primary-stat__text">
                Minecraft
                <span class="primary-stat__counter">
                  {{
                    formats
                      .list(
                        moreVersions > 0
                          ? [...supportsMcVersions, '$$$_REPLACEME_$$$']
                          : supportsMcVersions
                      )
                      .replace('$$$_REPLACEME_$$$', '')
                  }}
                  <template v-if="moreVersions > 0">
                    <NuxtLink
                      :to="`/${project.project_type}/${route.params.id}/versions`"
                      class="text-link"
                    >
                      {{ moreVersions }} more
                    </NuxtLink>
                  </template>
                </span>
              </div>
            </div>
            <div
              v-if="
                !(project.loaders.length === 1 && project.loaders[0] === 'datapack') &&
                project.project_type !== 'resourcepack'
              "
              class="primary-stat"
            >
              <WrenchIcon class="primary-stat__icon" aria-hidden="true" />
              <div class="primary-stat__text">
                Supports
                <span class="primary-stat__counter">
                  {{ formats.list(project.loaders.map((x) => formatCategory(x))) }}
                </span>
              </div>
            </div>
            <div
              v-if="!['resourcepack', 'shader'].includes(project.project_type)"
              class="primary-stat"
            >
              <template
                v-if="project.client_side === 'optional' && project.server_side === 'optional'"
              >
                <GlobeIcon class="primary-stat__icon" aria-hidden="true" />
                <div class="primary-stat__text">
                  Either
                  <span class="primary-stat__counter">client or server-side</span>
                </div>
              </template>
              <template
                v-else-if="project.client_side === 'required' && project.server_side === 'required'"
              >
                <GlobeIcon class="primary-stat__icon" aria-hidden="true" />
                <div class="primary-stat__text">
                  Both
                  <span class="primary-stat__counter">client and server-side</span>
                </div>
              </template>
              <template
                v-else-if="
                  (project.client_side === 'optional' || project.client_side === 'required') &&
                  (project.server_side === 'optional' || project.server_side === 'unsupported')
                "
              >
                <ClientIcon class="primary-stat__icon" aria-hidden="true" />
                <div class="primary-stat__text">
                  <span class="primary-stat__counter">Client-side only</span>
                </div>
              </template>
              <template
                v-else-if="
                  (project.server_side === 'optional' || project.client_side === 'required') &&
                  (project.client_side === 'optional' || project.server_side === 'unsupported')
                "
              >
                <ServerIcon class="primary-stat__icon" aria-hidden="true" />
                <div class="primary-stat__text">
                  <span class="primary-stat__counter">Server-side only</span>
                </div>
              </template>
              <template
                v-else-if="
                  project.server_side === 'unsupported' && project.client_side === 'unsupported'
                "
              >
                <BanIcon class="primary-stat__icon" aria-hidden="true" />
                <div class="primary-stat__text">
                  <span class="primary-stat__counter">Unsupported</span>
                </div>
              </template>
            </div>
            <div class="primary-stat">
              <LicenseIcon class="primary-stat__icon" aria-hidden="true" />
              <div class="primary-stat__text">
                Licensed
                <a
                  v-if="project.license.url"
                  class="text-link"
                  :href="project.license.url"
                  rel="noopener nofollow ugc"
                >
                  {{ licenseIdDisplay }}
                  <ExternalIcon />
                </a>
                <span v-else>{{ licenseIdDisplay }}</span>
              </div>
            </div>
          </div>
          <div class="button-group-long">
            <Button @click="$refs.modalShare.show(`${getProjectUrl()}`)">
              <ShareIcon />
              Share
            </Button>
            <nuxt-link
              v-if="cosmetics.developerMode"
              :to="`/panel/${route.params.id}`"
              class="dev-button"
            >
              <WrenchIcon />
            </nuxt-link>

          </div>
        </div>
        <div v-if="project.links.length > 0" class="card">
          <h2>Links</h2>
          <div class="links">
            <CustomLink
              v-for="(link, index) in project.links"
              :key="index"
              :url="link.url"
              :icon="link.icon"
              :text="link.text"
            />
          </div>
        </div>
        <div class="card">
          <h2>Members</h2>
          <a
            v-for="member in allMembers"
            :key="member.name"
            class="team-member columns button-base button-transparent"
            :href="member.link"
            :target="external()"
          >
            <Avatar :src="member.icon" :alt="member.name" size="sm" circle />

            <div class="member-info">
              <p class="name">{{ member.name }}</p>
              <p class="role">
                {{ member.role }}
              </p>
            </div>
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import {
  AlignLeftIcon as DescriptionIcon,
  Avatar,
  Button,
  ChevronRightIcon,
  ClientIcon,
  DownloadIcon,
  ExternalIcon,
  formatCategory,
  formatNumber,
  getProjectLink,
  GlobeIcon,
  HeartIcon,
  ImageIcon as GalleryIcon,
  LeftArrowIcon,
  ListSelector,
  Modal,
  PageBar,
  ScrollableMultiSelect,
  ServerIcon,
  ShareIcon,
  ShareModal,
  SlashIcon as BanIcon,
  Toggle,
  UnknownIcon,
  UpdatedIcon,
  VersionIcon,
} from 'omorphia'
import LicenseIcon from '~/assets/images/utils/book-text.svg'
import WrenchIcon from '~/assets/images/utils/wrench.svg'
import GameIcon from '~/assets/images/utils/game.svg'
import { computeVersions } from '~/helpers/projects'
import CustomLink from '~/components/ui/CustomLink.vue'
import {useCosmetics} from "~/composables/cosmetics";

const route = useRoute()
const config = useRuntimeConfig()
const cosmetics = useCosmetics()

const tags = useTags()
const vintl = useVIntl()
const { formats } = vintl

const selectingGameVersion = ref(false)
const selectingPlatform = ref(false)

if (!route.params.id || !(route.params.type === 'mod' || route.params.type === 'project')) {
  throw createError({
    fatal: true,
    statusCode: 404,
    message: 'The page could not be found',
  })
}

let project, allMembers, versions
try {
  ;[{ data: project }, { data: allMembers }, { data: versions }] = await Promise.all([
    useAsyncData(
      `project/${route.params.id}`,
      () => $fetch(`https://api.beehive.sh/projects/${route.params.id}`),
      {
        transform: (project) => {
          if (project) {
            project.actualProjectType = JSON.parse(JSON.stringify(project.project_type))

            if (process.client && history.state && history.state.overrideProjectType) {
              project.project_type = history.state.overrideProjectType
            }
          }

          return project
        },
      }
    ),
    useAsyncData(`project/${route.params.id}/members`, () =>
      $fetch(`https://api.beehive.sh/teams/${route.params.id}`)
    ),
    useAsyncData(`project/${route.params.id}/version`, () =>
      $fetch(`https://api.beehive.sh/versions/${route.params.id}`)
    ),
  ])

  versions = shallowRef(toRaw(versions))
} catch (error) {
  throw createError({
    fatal: true,
    statusCode: 404,
    message: 'Project not found',
  })
}

if (!project.value) {
  throw createError({
    fatal: true,
    statusCode: 404,
    message: 'Project not found',
  })
}

if (project.value.project_type !== route.params.type) {
  let path = route.fullPath.split('/')
  path.splice(0, 3)
  path = path.filter((x) => x)

  await navigateTo(
    `/${project.value.project_type}/${route.params.id}${
      path.length > 0 ? `/${path.join('/')}` : ''
    }`,
    { redirectCode: 301, replace: true }
  )
}

versions.value = computeVersions(versions.value)

const selectedGameVersion = ref(null)
const selectedPlatform = ref(null)

const platformSuggestions = computed(() => {
  const validPlatformsSet = new Set()

  versions.value.forEach((version) => {
    if (!selectedGameVersion.value || version.game_versions.includes(selectedGameVersion.value)) {
      version.loaders.forEach((platform) => validPlatformsSet.add(platform))
    }
  })

  const validPlatforms = [...validPlatformsSet]

  return [
    ...validPlatforms.map((platform) => ({
      platform,
      valid: true,
    })),
    ...project.value.loaders
      .filter((x) => !validPlatforms.includes(x))
      .map((platform) => ({
        platform,
        valid: false,
      })),
  ].sort((a, b) => {
    const compareValid = b.valid - a.valid
    if (compareValid !== 0) {
      return compareValid
    }

    return a.platform.localeCompare(b.platform)
  })
})

const gameVersionSuggestions = computed(() => {
  const validGameVersionsSet = new Set()

  versions.value.forEach((version) => {
    if (!selectedPlatform.value || version.loaders.includes(selectedPlatform.value)) {
      version.game_versions.forEach((gameVersion) => validGameVersionsSet.add(gameVersion))
    }
  })

  const validGameVersions = [...validGameVersionsSet]

  return [
    ...validGameVersions.map((gameVersion) => ({
      version: gameVersion,
      valid: true,
    })),
    ...project.value.game_versions
      .filter((x) => !validGameVersions.includes(x))
      .map((gameVersions) => ({
        version: gameVersions,
        valid: false,
      })),
  ]
    .filter(
      (version) =>
        showSnapshots.value ||
        allGameVersionsSorted.value.find((x) => x.version === version.version).version_type !==
          'snapshot'
    )
    .sort((a, b) => {
      const compareValid = b.valid - a.valid

      if (compareValid !== 0) {
        return compareValid
      }

      const indexA = allGameVersionsSorted.value.findIndex((x) => x.version === a.version)
      const indexB = allGameVersionsSorted.value.findIndex((x) => x.version === b.version)

      return indexA - indexB
    })
})

const selectedVersion = computed(() => {
  let platform = selectedPlatform.value
  let gameVersion = selectedGameVersion.value

  if (!platform && project.value.loaders.length === 1) {
    platform = project.value.loaders[0]
  }

  if (!gameVersion && project.value.game_versions.length === 1) {
    gameVersion = project.value.game_versions[0]
  }

  const matchesSelection = (version) =>
    version.loaders.includes(platform) && version.game_versions.includes(gameVersion)

  const nonAlphas = versions.value.filter(
    (version) => version.version_type !== 'alpha' && matchesSelection(version)
  )

  return nonAlphas.length > 0
    ? nonAlphas[0]
    : versions.value.find((version) => matchesSelection(version)) || null
})

const showSnapshots = ref(false)

const highlightGameVersion = ref(false)
const highlightPlatform = ref(false)

const gameVersionQuery = ref('')

const licenseIdDisplay = computed(() => {
  const id = project.value.license.id

  if (id === 'LicenseRef-All-Rights-Reserved') {
    return 'All rights reserved'
  } else if (id.includes('LicenseRef')) {
    return id.replaceAll('LicenseRef-', '').replaceAll('-', ' ')
  } else {
    return id
  }
})
const featuredGalleryImage = computed(() => project.value.gallery.find((img) => img.featured))

function getProjectUrl() {
  return `${config.public.siteUrl}/${project.value.project_type}/${route.params.id}`
}

function toColor(color) {
  color >>>= 0
  const b = color & 0xff
  const g = (color & 0xff00) >>> 8
  const r = (color & 0xff0000) >>> 16
  return 'rgba(' + [r, g, b, 0.5].join(',') + ')'
}

const title = `${project.value.title} - Minecraft Mod`
const description = `${project.value.description} - Download the Minecraft mod ${
  project.value.title
} by ${allMembers.value.find((x) => x.role === 'Owner')?.name} on Beehive`

if (!route.name.startsWith('type-id-settings')) {
  useSeoMeta({
    title,
    description,
    ogTitle: title,
    ogDescription: project.value.description,
    ogImage: project.value.icon_url,
    robots: 'all',
  })
}

const downloadModal = ref(null)

const allGameVersionsSorted = computed(() =>
  tags.value.gameVersions.sort((a, b) => {
    return new Date(b.date) - new Date(a.date)
  })
)

const supportsMcVersions = computed(() => {
  const allMcVersions = allGameVersionsSorted.value
  const versions = project.value.game_versions.slice()
  const display = []
  if (
    versions.length > 0 &&
    allMcVersions.some((v) => v.version === versions[0] && v.version_type !== 'release')
  ) {
    display.push(versions[0])
  }
  display.push(
    ...allMcVersions
      .filter((v) => versions.includes(v.version) && v.version_type === 'release')
      .slice(0, 4)
      .map((v) => v.version)
  )

  return display
})

const moreVersions = computed(() => {
  return project.value.game_versions.length - supportsMcVersions.value.length
})
</script>
<style lang="scss" scoped>
.dev-button {
  background-color: var(--color-button-bg);
  padding: 0.5rem;
  border-radius: 0.5rem;

  display: flex;
  align-items: center;
  justify-content: center;

  &:hover {
    filter: brightness(1.2);
  }
}

.card {
  padding: 1.25rem;

  h2:first-child {
    margin-bottom: var(--gap-md);
  }
}

.about {
  padding: var(--gap-xl) calc(var(--gap-xl) - var(--gap-sm));
  grid-area: header;

  p {
    margin: 0;
  }

  > :not(.categories) {
    margin-inline: var(--gap-sm);
  }

  .description {
    line-height: 1.3;
    overflow-wrap: break-word;

    margin-bottom: 0.5rem;
    font-size: var(--font-size-nm);
  }

  .categories {
    margin-bottom: var(--gap-md);
    color: var(--color-secondary);
    font-size: var(--font-size-nm);
  }

  .dates {
    margin: 0.75rem 0;

    .date {
      color: var(--color-secondary);
      font-size: var(--font-size-nm);
      display: flex;
      align-items: center;
      margin-bottom: 0.25rem;
      cursor: default;

      .label {
        margin-right: 0.25rem;
      }

      svg {
        height: 1rem;
        margin-right: 0.25rem;
      }
    }
  }
}

.project-header {
  padding: 0 0 var(--gap-md) 0;
  display: grid;
  grid-template-areas: 'icon text primary-actions gallery' 'user-actions user-actions user-actions gallery';
  grid-template-columns: min-content 2fr auto auto;
  grid-template-rows: min-content 1fr min-content;
  gap: var(--gap-md);
  margin: 0;
  background: none;
  border-radius: unset;

  .project-header__text {
    grid-area: text;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    justify-content: flex-start;
    gap: 0.5rem;

    h1,
    p {
      margin: 0;
    }
  }

  .primary-actions {
    grid-area: primary-actions;

    .btn {
      padding: 0.75rem 1.5rem;
    }
  }

  .user-actions {
    grid-area: user-actions;
    display: flex;
    gap: 0.25rem;
  }

  .project__icon {
    grid-area: icon;
    background-color: transparent;
    border: none;
  }

  .button-section {
    grid-area: button-section;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    justify-content: center;
    gap: var(--gap-sm);
    margin-left: auto;

    .group {
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: var(--gap-sm);
    }

    .actions {
      .btn {
        color: var(--color-base);
      }
    }

    .server {
      background-color: var(--color-blue);
      color: var(--color-accent-contrast);
    }

    .support {
      background-color: var(--color-purple);
      color: var(--color-accent-contrast);
    }
  }
}

@media screen and (max-width: 768px) {
  .project-header {
    grid-template-areas:
      'icon title'
      'button-section button-section';
    grid-template-columns: 6rem auto;
    grid-template-rows: auto auto;
    gap: var(--gap-sm);

    .title {
      h1 {
        font-size: var(--font-size-lg);
        font-weight: 700;
      }
    }

    .button-section {
      flex-direction: row;
      align-items: flex-start;
      justify-content: flex-start;
      margin-left: 0;
    }
  }
}

.project-info {
  height: auto;
  overflow: hidden;
}

.featured-header {
  display: flex;
  justify-content: space-between;
  align-items: baseline;

  .sidebar-card-header {
    height: 23px;
  }

  .goto-link {
    margin-bottom: 0.3rem;
  }
}

.featured-version {
  display: flex;
  flex-direction: row;
  padding: 0.5rem;

  .download {
    height: 2.5rem;
    width: 2.5rem;
    margin-right: 0.75rem;

    svg {
      width: 1.5rem;
      height: 1.5rem;
    }
  }

  .info {
    display: flex;
    flex-direction: column;

    .top {
      font-weight: bold;
      word-wrap: break-word;
      overflow-wrap: anywhere;
    }
  }
}

.links {
  display: flex;
  flex-direction: column;
  gap: var(--gap-md);
}

.team-member {
  align-items: center;
  padding: 0.25rem 0.5rem;
  margin-left: -0.5rem;

  .member-info {
    overflow: hidden;
    margin: auto 0 auto 0.75rem;

    .name {
      font-weight: bold;
    }

    p {
      font-size: var(--font-size-sm);
      margin: 0.2rem 0;
    }
  }
}

.infos {
  .info {
    display: flex;
    margin: 0.5rem 0;

    .key {
      font-weight: bold;
      color: var(--color-secondary);
      width: 40%;
    }

    .value {
      width: 50%;

      &::first-letter {
        text-transform: capitalize;
      }

      &.lowercase {
        &::first-letter {
          text-transform: none;
        }
      }
    }

    .uppercase {
      text-transform: uppercase;
    }
  }
}

@media screen and (max-width: 550px) {
  .title a {
    display: none;
  }
}

@media screen and (max-width: 800px) {
  .project-navigation {
    display: block;
    overflow-x: auto;
    overflow-wrap: break-word;
    overflow-y: hidden;
  }
}

@media screen and (min-width: 1024px) {
  .content {
    max-width: calc(1280px - 21rem);
  }
}

.status-buttons {
  margin-top: var(--gap-sm);
}

.mod-message__title {
  font-weight: bold;
  margin-bottom: var(--gap-xs);
  font-size: 1.125rem;
}

.modal-license {
  padding: var(--gap-lg);
}

.settings-header {
  display: flex;
  flex-direction: row;
  gap: var(--gap-sm);
  align-items: center;
  margin-bottom: var(--gap-lg);

  .settings-header__icon {
    flex-shrink: 0;
  }

  .settings-header__text {
    h1 {
      font-size: var(--font-size-md);
      margin-top: 0;
      margin-bottom: var(--gap-sm);
    }
  }
}

.normal-page__sidebar {
  padding-top: 1rem;
}

.normal-page__sidebar .mod-button {
  margin-top: var(--gap-sm);
}

.support-card {
  display: flex;
  flex-direction: column;
  gap: var(--gap-md);
  padding-bottom: var(--gap-xl);

  .card-content {
    display: flex;
    flex-direction: column;
    gap: var(--gap-md);
  }
}

.one-time-section {
  display: flex;
  flex-direction: column;
  gap: var(--gap-sm);

  .one-time-section__row {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    gap: var(--gap-md);
  }
}

.overflow-button {
  padding: var(--gap-sm);

  svg {
    margin: 0;
  }
}

.featured-gallery-image {
  img {
    display: block;
    width: 100%;
    border-radius: 15px;
    aspect-ratio: 2 / 1;
    object-fit: cover;
    border: 1px solid var(--color-divider);
  }
}

.breadcrumbs {
  display: flex;
  align-items: center;
  color: var(--color-secondary);
  margin-bottom: 2rem;
  flex-wrap: wrap;

  span:not(.current) {
    color: var(--color-base);
  }

  svg {
    margin-inline: 0.5rem;
  }
}

.search-row {
  margin-bottom: 1rem;
}

.clickable-header {
  display: flex;
  align-items: center;
}

.sidebar-section {
  margin-bottom: 2rem;

  &.gallery {
    img {
      width: 20rem;
      border-radius: 12px;
      aspect-ratio: 2 / 1;
    }
  }
}

.nav-container {
  margin-bottom: 1rem;
}

.proj-header {
  display: grid;
  grid-template-columns: min-content 1fr auto;
  margin-bottom: 1rem;

  .summary {
    color: var(--color-secondary);
    font-size: var(--font-size-sm);
    margin-right: 5rem;
  }

  @media screen and (max-width: 900px) {
    grid-template-columns: min-content 1fr;

    .mod-buttons {
      margin-top: var(--gap-lg);
      grid-column: span 2;
    }
  }
}

.game-icon {
  width: 5rem;
  height: 5rem;
  margin-right: 1rem;
  box-shadow: none;
  position: relative;
  aspect-ratio: 1 / 1;
  border-radius: 14px;
  border: 1px solid var(--color-divider);
  background-color: var(--color-raised-bg);

  .avatar {
    --size: 5rem !important;
    background-color: transparent;
    border: none;
    box-shadow: none;
    border-radius: inherit;
  }
}

.game-title {
  display: flex;
  flex-direction: column;

  .game-name {
    display: flex;
    gap: 0.5rem;
    align-items: flex-start;

    h1 {
      margin: 0;
      font-size: var(--font-size-xl);
    }

    .btn {
      margin-top: -0.25rem;
    }
  }

  .game-subtitle {
    display: flex;
    gap: 1rem;
    margin-top: 0.5rem;
    color: var(--color-base);

    span {
      display: flex;
      align-items: center;
      gap: 0.25rem;
      font-weight: 500;

      svg {
        width: 1.25rem;
        height: 1.25rem;
      }
    }
  }
}

.download-selectors {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;

  .btn {
    width: 100%;

    .dropdown-icon {
      margin-left: auto;
    }
  }
}

.new-nav {
  display: flex;
  justify-content: space-between;
  border-bottom: 2px solid var(--color-divider);
  margin-bottom: var(--gap-lg);

  > div {
    display: flex;
    justify-content: flex-start;
  }

  svg {
    height: 1.2rem;
    width: 1.2rem;
  }

  a {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-weight: 600;
    border-bottom: 3px solid transparent;
    padding: 0.75rem 1rem;
    margin-bottom: -2px;

    &.router-link-exact-active {
      color: var(--color-contrast);
      border-color: var(--color-brand);
    }
  }
}

.supports-details {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1rem;

  > div {
    margin: 0;
  }
}

.mod-buttons {
  display: flex;
  gap: 0.5rem;
}

.mod-stats {
  display: flex;
  margin-top: 0.5rem;
  gap: 0.75rem;
  flex-wrap: wrap;

  .stat {
    display: flex;
    flex-direction: row;
    gap: 0.25rem;
    justify-content: center;
    align-content: center;

    span {
      display: flex;
      align-items: center;
    }

    .label {
      color: var(--color-secondary);
    }

    .value {
      font-weight: 500;
    }
  }
}

.normal-page__info {
  h2 {
    font-size: var(--font-size-nm) !important;
    font-weight: 700;
    color: var(--color-contrast);
    //font-family: 'Inter', sans-serif;
  }

  > div {
    margin: 0;
  }

  > div:not(:first-child) {
    margin-top: 1rem;
  }
}

.button-group-long {
  display: flex;
  width: 100%;
  gap: 0.5rem;
  margin-top: 1rem;

  > .btn:not(.icon-only) {
    width: 100%;
  }
}

.primary-stat {
  .primary-stat__text {
    .categories {
      margin-top: 0.5rem;
    }
  }
}

@media screen and (max-width: 900px) {
  .page-bar .desktop-settings-button {
    display: none;
  }
}

.download-modal-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
  gap: var(--gap-lg);
  height: 27rem;
  padding: var(--gap-lg);

  > .list-selection-page {
    display: flex;
    flex-direction: column;
    gap: var(--gap-md);

    .scrollable-pane-wrapper {
      max-height: 15rem;
      flex-shrink: 1;
      width: 20rem;

      :deep(.wrapper-wrapper) {
        background-color: var(--color-bg);
        border-radius: var(--radius-md);
        padding: var(--gap-sm);

        &::before {
          background-image: linear-gradient(var(--color-bg), transparent);
        }

        &::after {
          background-image: linear-gradient(transparent, var(--color-bg));
        }
      }

      .list-selector.incompatible {
        color: var(--color-red);
        opacity: 0.5;
      }
    }

    .heading {
      display: flex;
      justify-content: space-between;
      align-items: center;

      h2 {
        margin: 0;
        font-size: var(--font-size-md);
      }
    }
  }

  > .main-page {
    display: flex;
    flex-direction: column;
    gap: var(--gap-sm);
    width: 18rem;

    .btn {
      width: 100%;
    }

    .btn:not(.btn-primary) {
      justify-content: left;
      text-align: left;

      &:disabled {
        background-color: transparent;

        svg:last-child {
          display: none;
        }
      }

      svg:last-child {
        margin-left: auto;
      }
    }

    .input-group {
      display: flex;
      flex-wrap: nowrap;

      .help-icon {
        margin-right: 1rem;
      }

      .btn.warning-outline {
        border-color: var(--color-red);
        background-color: var(--color-warning-banner-bg);
      }
    }
  }
}

.toggle-option {
  margin-inline: 0.75rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 5px;

  label {
    flex-grow: 1;
    font-weight: 600;
  }

  :not(:focus-visible) {
    box-shadow: none;
  }
}
</style>
