<script setup lang="ts">
	import { ref } from 'vue'
	import Scratcher from './components/Scratcher.vue'

	let open = ref<boolean>(false)

	window.addEventListener('message', (event) => {
		const { action } = event.data

		if (action === 'openScratcher') {
			open.value = true
		}
	})
</script>

<template>
	<main>
		<Scratcher v-if="open" />
	</main>
</template>

<style scoped>
	main {
		margin: auto 0;
	}
</style>

<style>
	.font-kadwa {
		font-family: 'Kadwa', serif;
		font-weight: 700;
		font-style: normal;
		font-size: 3em;

		background: linear-gradient(-98deg, #ff0000 0%, #990000 91%);
		-webkit-background-clip: text;
		background-clip: text;
		color: transparent;
	}
	*,
	*::after,
	*::before {
		box-sizing: content-box;
		-webkit-user-select: none; /* Safari */
		-ms-user-select: none; /* IE 10 and IE 11 */
		user-select: none; /* Standard syntax */
	}

	img {
		max-width: 100%;
	}
</style>
