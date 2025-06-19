<script setup lang="ts">
	import Scratcher from './components/Scratcher.vue'
</script>

<template>
	<main>
		<Scratcher />
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
</style>
