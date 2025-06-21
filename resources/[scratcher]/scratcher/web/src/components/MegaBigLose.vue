<script setup lang="ts">
	import KeepGambling from '../assets/scratcher/keep-gambling.jpg'
</script>

<template>
	<div>
		<img :src="KeepGambling" alt="Keep gambling" />
		<h2>Try again next time</h2>
	</div>
</template>

<style scoped>
	div {
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		box-shadow: 0 22px 70px 4px rgba(0, 0, 0, 0.56);
		border-radius: 1rem;
		animation: pop 0.75s linear;
		width: 100%;
		z-index: 3;
		padding: 4rem 2rem;
		padding-bottom: 2rem;
		min-width: 15rem;
		background: radial-gradient(
			circle at center,
			#e0e0e0 0%,
			#c0c0c0 40%,
			#a0a0a0 70%,
			#888888 100%
		);
	}
	h2 {
		font-family: Kadwa, serif;
		font-size: 2.5rem;
		color: black;
		margin-top: 2rem;
	}

	@keyframes pop {
		0% {
			opacity: 0;
		}
		100% {
			opacity: 1;
		}
	}

	img {
		display: block;
		max-width: 80%;
		pointer-events: none;
		margin: 0 auto;
		border-radius: 0.25rem;
	}
</style>
