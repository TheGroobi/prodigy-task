<script setup>
	import KeepGambling from '../assets/scratcher/keep-gambling.jpg'
</script>
<template>
	<div>
		<img :src="KeepGambling" alt="Keep gambling" />
		<!--<h2>Try again next time</h2>-->
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
		animation: pop 0.5s linear;
		width: 125%;
		z-index: 3;
	}
	h2 {
		font-family: Kadwa, serif;
		font-size: 3rem;
		padding: 4rem;
		min-width: 15rem;
		background: radial-gradient(
			circle at center,
			#e0e0e0 0%,
			#c0c0c0 40%,
			#a0a0a0 70%,
			#888888 100%
		);
		color: black;
	}

	@keyframes pop {
		0% {
			transform: translate(-50%, -50%) scale(0.9);
			opacity: 0;
		}
		50% {
			opacity: 1;
			transform: translate(-50%, -50%) scale(1.1);
		}
		100% {
			transform: translate(-50%, -50%) scale(1);
			opacity: 1;
		}
	}

	img {
		border-radius: 1rem;
		min-height: 100%;
		display: block;
		pointer-events: none;
	}
</style>
