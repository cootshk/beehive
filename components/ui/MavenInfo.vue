<template>
  <div class="maven-info">
    <div class="selectors">
      <Multiselect
        v-model="language"
        :options="['Groovy', 'Kotlin Script']"
        :searchable="true"
        :show-no-results="false"
        :close-on-select="true"
        :clear-search-on-select="false"
        :show-labels="false"
        :allow-empty="false"
        placeholder="Choose Language..."
        @update:model-value="updateTextBox"
      />
      <Multiselect
        v-model="plugin"
        :options="['Fabric Loom', 'Fabric Loom (Legacy)', 'NeoGradle', 'Arch Loom', 'ForgeGradle']"
        :searchable="true"
        :show-no-results="false"
        :close-on-select="true"
        :clear-search-on-select="false"
        :show-labels="false"
        :allow-empty="false"
        placeholder="Choose Plugin..."
        @update:model-value="updateTextBox"
      />
    </div>
    <div class="maven-text">
      <textarea v-model="content" disabled />
      <Button v-tooltip="'Copy Text'" icon-only class="copy-button transparent" @click="copyText">
        <ClipboardCopyIcon />
      </Button>
    </div>
    <div class="maven-description">
      <p>
        All maven information is gathered from the Team Resourceful maven, you will need to use the repository below to use the maven information
      </p>
      <CopyCode class="maven-copy" text="https://maven.teamresourceful.com/repository/maven-public/" />
    </div>
  </div>
</template>

<script setup>
import { Button, ClipboardCopyIcon } from "omorphia";
import {Multiselect} from "vue-multiselect";
import CopyCode from "~/components/ui/CopyCode.vue";

const props = defineProps({
  group: {
    type: String,
    default: '',
  },
  artifact: {
    type: String,
    default: '',
  },
  version: {
    type: String,
    default: '',
  },
})

const content = ref(null)
const language = ref('Groovy');
const plugin = ref('Fabric Loom');

const updateTextBox = () => {
  const plug = plugin.value;
  const lang = language.value;
  const isLegacyLoom = plug === 'Fabric Loom (Legacy)' || plug === 'Arch Loom';
  const isModernGradle = plug === 'Fabric Loom' || plug === 'NeoGradle';
  if (isLegacyLoom) {
    if (lang === 'Groovy') {
      content.value = `modImplementation "${props.group}:${props.artifact}:${props.version}"`;
    } else if (lang === 'Kotlin Script') {
      content.value = `modImplementation(group = "${props.group}", name = "${props.artifact}", version = "${props.version}")`;
    }
  } else if (isModernGradle) {
    if (lang === 'Groovy') {
      content.value = `implementation "${props.group}:${props.artifact}:${props.version}"`;
    } else if (lang === 'Kotlin Script') {
      content.value = `implementation("${props.group}:${props.artifact}:${props.version}")`;
    }
  } else if (plug === 'ForgeGradle') {
    if (lang === 'Groovy') {
      content.value = `implementation fg.deobf("${props.group}:${props.artifact}:${props.version}")`;
    } else if (lang === 'Kotlin Script') {
      content.value = `implementation(fg.deobf("${props.group}:${props.artifact}:${props.version}"))`;
    }
  }
}

const copyText = async () => {
  await navigator.clipboard.writeText(content.value)
}

updateTextBox()

</script>

<style scoped>

.maven-info {
  display: flex;
  flex-direction: column;
  gap: 1rem;

  .selectors {
    display: flex;
    gap: 1rem;
  }

  .maven-text {
    position: relative;
    height: 100%;

    textarea {
      width: 100%;
      margin: 0;
      overflow: hidden;
      resize: none;

      font-family: var(--mono-font)
    }

    &:hover {
      .copy-button {
        opacity: 1;
      }
    }
  }

  .maven-copy {
    width: 100%;
    max-width: 100%;

    span {
      max-width: 100% !important;
    }
  }

  .maven-description {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;

    p {
      margin: 0;
    }
  }

  .copy-button {
    position: absolute;
    top: 0;
    right: 0;
    margin: var(--gap-sm);
    transition: all 0.2s ease-in-out;
    opacity: 0;

    @media (prefers-reduced-motion) {
      transition: none !important;
    }
  }
}
</style>
