<template>
  <div class="search-page normal-page">
    <Head>
      <Title>Search projects - Beehive</Title>
    </Head>
    <section class="normal-page__header">
      <GameBanner game="minecraft_java"/>
      <PageBar class="filter-row">
        <span class="page-bar__title">Sort by</span>
        <div class="sort-by-desktop">
          <button
            v-for="sortMode in sortModes.filter((x) => x.featured || sortType === x.id)"
            :key="`sort-mode-${sortMode.id}`"
            class="button-base nav-button"
            :class="{ 'router-link-exact-active': sortType === sortMode.id }"
            @click="
              () => {
                sortType = sortMode.id
                onSearchChange(1)
              }
            "
          >
            <TopIcon v-if="sortMode.id === 'relevance'" aria-hidden="true"/>
            <NewIcon v-else-if="sortMode.id === 'newest'" aria-hidden="true"/>
            <HistoryIcon v-else-if="sortMode.id === 'updated'" aria-hidden="true"/>
            <UnknownIcon v-else aria-hidden="true"/>
            {{ sortTypeDisplayNames[sortMode.id] }}
          </button>
        </div>
        <div class="sort-by-mobile">
          <OverflowMenu
            class="btn btn-dropdown-animation"
            position="bottom"
            direction="right"
            :options="
              sortModes
                .filter((x) => sortType !== x.id)
                .map((x) => {
                  return {
                    id: x.id,
                    action: () => {
                      sortType = x.id
                      onSearchChange(1)
                    }
                  }
                })
            "
          >
            <TopIcon v-if="sortType === 'relevance'" aria-hidden="true"/>
            <NewIcon v-else-if="sortType === 'newest'" aria-hidden="true"/>
            <HistoryIcon v-else-if="sortType === 'updated'" aria-hidden="true"/>
            <HeartIcon v-else-if="sortType === 'follows'" aria-hidden="true"/>
            <DownloadIcon v-else-if="sortType === 'downloads'" aria-hidden="true"/>
            <UnknownIcon v-else aria-hidden="true"/>
            {{ sortTypeDisplayNames[sortType] }}
            <DropdownIcon/>
            <template #relevance>
              <TopIcon aria-hidden="true"/>
              Top
            </template>
            <template #newest>
              <NewIcon aria-hidden="true"/>
              New
            </template>
            <template #updated>
              <HistoryIcon aria-hidden="true"/>
              Updated Recently
            </template>
          </OverflowMenu>
        </div>
        <template #right>
          <span class="view-options-title page-bar__title">View as</span>
          <div class="page-bar__buttons">
            <button
              v-tooltip="`List`"
              aria-label="List"
              class="btn icon-only"
              :class="{
                'btn-brand-highlight': cosmetics.displayMode === 'list',
              }"
              @click="setSearchDisplayMode('list')"
            >
              <ListIcon/>
            </button>
            <button
              v-tooltip="`Grid`"
              aria-label="Grid"
              class="btn icon-only"
              :class="{
                'btn-brand-highlight': cosmetics.displayMode === 'grid',
              }"
              @click="setSearchDisplayMode('grid')"
            >
              <GridIcon/>
            </button>
          </div>
        </template>
      </PageBar>
    </section>
    <aside
      :class="{
        'normal-page__sidebar': true,
        open: sidebarMenuOpen,
      }"
      aria-label="Filters"
    >
      <section class="card filters-card">
        <h2>Site Statistics</h2>
        <div class="filter-section expanded">
          <div class="content-wrapper">
            <div class="content">
              <span class="statistic-line">
                <DownloadIcon/>
                <strong>{{ formatNumber(statistics?.downloads || 0) }}</strong>
                 Downloads
              </span>
              <span class="statistic-line">
                <HeartIcon/>
                <strong>{{ formatNumber(statistics?.followers || 0) }}</strong>
                 Followers
              </span>
              <span class="statistic-line">
                <FileIcon/>
                <strong>{{ formatNumber(statistics?.files || 0) }}</strong>
                 Files
              </span>
              <span class="statistic-line">
                <ScaleIcon/>
                <strong>{{ formatBytes(statistics?.size || 0) }}</strong>
                 Storage
              </span>
              <span class="statistic-line">
                <BoxIcon/>
                <strong>{{ formatNumber(statistics?.projects || 0) }}</strong>
                 Projects
              </span>
            </div>
          </div>
        </div>
      </section>
    </aside>
    <section class="normal-page__content">
      <div class="search-row">
        <div class="iconified-input">
          <label class="hidden" for="search">Search</label>
          <SearchIcon aria-hidden="true"/>
          <input
            id="search"
            v-model="query"
            type="text"
            name="search"
            :placeholder="`Search projects...`"
            autocomplete="off"
            @input="onSearchChange(1)"
          />
          <Button v-if="query" class="r-btn" @click="() => (query = '')">
            <XIcon/>
          </Button>
        </div>
        <Pagination
          :page="currentPage"
          :count="pageCount"
          :link-function="(x) => getSearchUrl(x <= 1 ? 0 : (x - 1) * 20)"
          @switch-page="onSearchChange"
        />
      </div>
      <AnimatedLogo v-if="searchLoading && !noLoad"/>
      <div
        v-else-if="
          results && results.hits && results.hits.length === 0 && (!searchLoading || noLoad)
        "
        class="no-results"
      >
        <FrownIcon/>
        <p v-if="query">We couldn't find any results matching "{{ query }}"</p>
        <p v-else>We couldn't find any results.</p>
      </div>
      <div v-else class="search-results-container">
        <div
          id="search-results"
          class="project-list"
          :class="
            'display-mode--' +
            (cosmetics.displayMode)
          "
          role="list"
          aria-label="Search results"
        >
          <ProjectCardV2
            v-for="result in results?.hits"
            :id="result.slug"
            :key="result.slug"
            :display="cosmetics.displayMode"
            :featured-image="result.featured_gallery ? result.featured_gallery : result.gallery[0]"
            type="mod"
            :author="result.author"
            :name="result.title"
            :description="result.description"
            :created-at="result.published"
            :updated-at="result.updated"
            :downloads="result.downloads.toString()"
            :follows="result.followers.toString()"
            :icon-url="result.icon_url"
            :client-side="result.client_side"
            :server-side="result.server_side"
            :search="true"
            :show-updated-date="sortType !== 'newest'"
            :hide-loaders="true"
            :color="result.color"
            :from-now="fromNow"
          />
        </div>
      </div>
      <div class="pagination-container">
        <Pagination
          :page="currentPage"
          :count="pageCount"
          :link-function="(x) => getSearchUrl(x <= 1 ? 0 : (x - 1) * MAX_RESULTS)"
          @switch-page="onSearchChangeToTop"
        />
      </div>
    </section>
  </div>
</template>
<script setup>
import {
  AnimatedLogo,
  BoxIcon,
  Button,
  DownloadIcon,
  DropdownIcon,
  FileIcon,
  formatBytes,
  formatNumber,
  GridIcon,
  HeartIcon,
  HistoryIcon,
  ListIcon,
  OverflowMenu,
  PageBar,
  Pagination,
  ScaleIcon,
  SearchIcon,
  UnknownIcon,
  XIcon,
} from 'omorphia'
import TopIcon from 'assets/images/utils/arrow-big-up-dash.svg'
import NewIcon from 'assets/images/utils/burst.svg'
import FrownIcon from 'assets/images/utils/frown.svg'
import GameBanner from '~/components/ui/GameBanner.vue'
import ProjectCardV2 from "~/components/ui/ProjectCardV2.vue";

const MAX_RESULTS = 20

const sortTypeDisplayNames = {
  relevance: 'Top',
  newest: 'New',
  updated: 'Updated recently',
}

const sidebarMenuOpen = ref(false)
const route = useRoute()
const cosmetics = useCosmetics()
const query = ref('')

const sortModes = shallowReadonly([
  {id: 'relevance', featured: true},
  {id: 'newest', featured: true},
  {id: 'updated', featured: true},
])

const sortType = ref('relevance')
const currentPage = ref(1)

const ogTitle = computed(
  () => `Search projects${query.value ? ' | ' + query.value : ''}`
)

const description = computed(
  () =>
    `Search and browse Minecraft mods on Beehive with instant, accurate search results.`
)

useSeoMeta({
  description,
  ogTitle,
  ogDescription: description,
})

if (route.query.q) {
  query.value = route.query.q
}
if (route.query.s) {
  sortType.value = route.query.s
}

if (route.query.o) {
  currentPage.value = Math.ceil(route.query.o / MAX_RESULTS) + 1
}

const noLoad = ref(false)
const {
  data: rawResults,
  refresh: refreshSearch,
  pending: searchLoading,
} = useLazyFetch(
  () => {
    const params = [`index=${sortType.value}`]

    if (query.value.length > 0) {
      params.push(`query=${encodeURIComponent(query.value.replace(/ /g, '+'))}`)
    }

    const offset = (currentPage.value - 1) * MAX_RESULTS
    if (currentPage.value !== 1) {
      params.push(`offset=${offset}`)
    }

    let url = 'search'

    if (params.length > 0) {
      for (let i = 0; i < params.length; i++) {
        url += i === 0 ? `?${params[i]}` : `&${params[i]}`
      }
    }

    return `https://api.beehive.sh/${url}`
  },
  {
    transform: (hits) => {
      noLoad.value = false
      return hits
    },
  }
)

const results = shallowRef(toRaw(rawResults))
const pageCount = computed(() =>
  results.value ? Math.ceil(results.value.total_hits / results.value.limit) : 1
)

const {data: statistics} = await useAsyncData(
  `statistics`,
  () => $fetch(`https://api.beehive.sh/statistics`)
)

function onSearchChange(newPageNumber) {
  noLoad.value = true

  currentPage.value = newPageNumber

  if (query.value === null) {
    return
  }

  refreshSearch()

  if (process.client) {
    const router = useRouter()
    const obj = getSearchUrl((currentPage.value - 1) * MAX_RESULTS, true)
    router.replace({path: route.path, query: obj})
  }
}

function getSearchUrl(offset, useObj) {
  const queryItems = []
  const obj = {}

  if (query.value) {
    queryItems.push(`q=${encodeURIComponent(query.value)}`)
    obj.q = query.value
  }
  if (offset > 0) {
    queryItems.push(`o=${offset}`)
    obj.o = offset
  }
  if (sortType.value !== 'relevance') {
    queryItems.push(`s=${encodeURIComponent(sortType.value)}`)
    obj.s = sortType.value
  }

  let url = `${route.path}`

  if (queryItems.length > 0) {
    url += `?${queryItems[0]}`

    for (let i = 1; i < queryItems.length; i++) {
      url += `&${queryItems[i]}`
    }
  }

  return useObj ? obj : url
}

function onSearchChangeToTop(newPageNumber) {
  if (process.client) {
    window.scrollTo({top: 0, behavior: 'smooth'})
  }

  onSearchChange(newPageNumber)
}

function setSearchDisplayMode(mode) {
  cosmetics.value.displayMode = mode
  saveCosmetics()
}
</script>

<style lang="scss" scoped>
.normal-page__content {
  // Passthrough children as grid items on mobile
  display: contents;

  @media screen and (min-width: 1024px) {
    display: block;
  }
}

// Move the filters "sidebar" on mobile underneath the search card
.normal-page__sidebar {
  grid-row: 3;

  // Always show on desktop
  @media screen and (min-width: 1024px) {
    display: block;
  }

  // Hide on mobile unless open
  display: none;

  &.open {
    display: block;
  }
}

.filter-row {
  margin-top: var(--gap-lg);
}

.no-results {
  display: flex;
  width: 100%;
  justify-content: center;
  align-items: center;
  gap: var(--gap-lg);

  svg {
    --_size: 5rem;
    width: var(--_size);
    height: var(--_size);
    color: var(--color-brand);

    :deep(circle) {
      fill: var(--color-brand-highlight);
    }
  }

  p {
    color: var(--color-contrast);
    font-size: var(--font-size-xl);
    font-weight: bold;
    max-width: 30rem;
  }

  @media screen and (max-width: 500px) {
    p {
      font-size: var(--font-size-nm);
    }
  }

  @media screen and (max-width: 300px) {
    p {
      font-size: var(--font-size-sm);
    }
  }
}

.loading-logo {
  margin: 2rem;
}

@media screen and (min-width: 860px) {
  .labeled-control {
    flex-wrap: nowrap !important;
    flex-direction: row !important;
  }
}

@media screen and (min-width: 1024px) {
  .sidebar-menu {
    display: block;
    margin-top: 0;
  }

  .sidebar-menu-close-button {
    display: none;
  }

  .labeled-control {
    flex-wrap: wrap !important;
    flex-direction: column !important;
  }
}

@media screen and (min-width: 1100px) {
  .labeled-control {
    flex-wrap: nowrap !important;
    flex-direction: row !important;
  }
}

h1 {
  margin-block: var(--gap-sm) var(--gap-lg);
  font-size: 2em;
  line-height: 1em;
}

.pagination-container {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: var(--gap-lg);
  flex-wrap: wrap;

  .count-dropdown {
    width: 5.5rem;
  }

  .animated-dropdown {
    margin-inline: var(--gap-sm);
  }
}

.type-header {
  margin-top: 1rem;
}

.filters-card {
  .card-title {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 1rem;

    h2 {
      margin: 0;
    }
  }

  .iconified-input {
    input {
      border: var(--button-border-width) solid var(--color-divider);
      box-shadow: none;
    }
  }

  h2 {
    font-size: var(--font-size-lg) !important;
  }
}

.statistic-line {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: var(--font-size-sm);
  color: var(--color-base);
  padding: 0.1rem 0;
}

.filter-section {
  display: flex;
  flex-direction: column;
  transition: padding-bottom 0.125s ease-in-out;

  .heading {
    display: flex;
    background-color: transparent;
    padding: 0.25rem 0;
    align-items: center;
    justify-content: space-between;
    width: 100%;
    margin-block: 0.5rem 0;
    font-size: var(--font-size-nm);

    svg {
      width: 1.25rem;
      height: 1.25rem;
      transition: rotate 0.25s ease-in-out;
    }
  }

  .content-wrapper {
    display: grid;
    grid-template-rows: 0fr;
    transition: grid-template-rows 0.25s ease-in-out;
  }

  .content {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    font-size: var(--font-size-sm);
    overflow: hidden;

    .see-more {
      color: #737d80;
    }

    > :last-child {
      margin-bottom: 0.5rem;
    }
  }

  &.expanded {
    .heading svg {
      rotate: 180deg;
    }

    .content-wrapper {
      grid-template-rows: 1fr;
    }
  }

  &:not(.expanded) {
    padding-bottom: 0.5rem;
  }

  &:not(:last-child):not(:empty) {
    border-bottom: 1px solid var(--color-divider);
  }

  .toggle-option {
    margin-inline: 0.75rem;
    display: flex;
    justify-content: space-between;
    align-items: center;

    label {
      flex-grow: 1;
      font-weight: 600;
    }

    :not(:focus-visible) {
      box-shadow: none;
    }
  }
}

.filters-search-row {
  display: flex;
  gap: var(--gap-sm);

  input {
    min-height: 36px;
    height: 36px;
  }

  .iconified-input {
    svg {
      width: 1rem;
      height: 1rem;
    }
  }
}

.sort-by-desktop {
  display: contents;
}

.sort-by-mobile {
  display: none;
}

.page-bar {
  @media screen and (max-width: 750px) {
    .sort-by-desktop {
      display: none;
    }

    .sort-by-mobile {
      display: contents;
    }
  }

  @media screen and (max-width: 600px) {
    padding-bottom: var(--gap-xs);

    .page-bar__title {
      display: none;
    }
  }
}
</style>
