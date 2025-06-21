<script setup lang="ts">
	import { onMounted, computed, ref } from 'vue'

	interface Props {
		prize: number
	}

	const props = defineProps<Props>()

	let displayPrize = ref<number>(0)

	onMounted(async () => {
		let delay = 10
		let jump = 1

		for (let i = 0; i <= props.prize; i += jump) {
			if (i > 100) {
				jump = 3
			} else if (i > 1000) {
				jump = 10
			} else if (i > 10000) {
				jump = 100
			}

			displayPrize.value = i
			await new Promise((res) => setTimeout(res, delay))
		}
		displayPrize.value = props.prize
	})

	const prizeClass = computed(() => {
		if (displayPrize.value >= 100000) return 'scale-xxl'
		if (displayPrize.value >= 10000) return 'scale-xl'
		if (displayPrize.value >= 1000) return 'scale-lg'
		if (displayPrize.value >= 500) return 'scale-md'
		if (displayPrize.value >= 100) return 'scale-sm'
		return ''
	})
</script>

<template>
	<div class="container">
		<h1>MEGA BIG WIN</h1>
		<h2 :class="['breathe', prizeClass]">${{ displayPrize.toString() }}</h2>
		<img src="../assets/scratcher/stars.png" />
		<img class="flipped" src="../assets/scratcher/stars.png" />
	</div>
</template>

<style scoped>
	img {
		width: 8rem;
		position: absolute;
		bottom: 1rem;
		right: 2rem;
		&.flipped {
			-webkit-transform: scaleX(-1);
			left: 2rem;
			right: unset;
			transform: scaleX(-1);
		}
	}
	@keyframes bg-position {
		0% {
			background-position: 0% 50%;
		}
		50% {
			background-position: 100% 50%;
		}
		100% {
			background-position: 0% 50%;
		}
	}

	@keyframes pop {
		0% {
			transform: translate(-50%, -50%) scale(0.8);
			opacity: 0;
		}
		35% {
			opacity: 1;
			transform: translate(-50%, -50%) scale(2);
		}
		100% {
			transform: translate(-50%, -50%) scale(1);
			opacity: 1;
		}
	}

	.container {
		position: absolute;
		left: 50%;
		top: 50%;
		transform: translate(-50%, -50%);
		z-index: 2;
		pointer-events: none;
		padding: 2rem;

		border-radius: 1rem;
		background: #bd223e;
		background: linear-gradient(
			90deg,
			rgba(255, 15, 15, 1) 0%,
			rgba(245, 110, 32, 1) 20%,
			rgba(253, 29, 29, 1) 50%,
			rgba(253, 93, 46, 1) 72%,
			rgba(252, 176, 69, 1) 100%
		);
		background-size: 400% 400%;
		animation: bg-position 7s linear infinite;
		animation: pop 0.75s linear;
		box-shadow:
			0 4px 8px 0 rgba(0, 0, 0, 0.2),
			0 6px 20px 0 rgba(0, 0, 0, 0.19);
	}

	h1 {
		font-size: 5rem;
		margin-bottom: 1rem;
		-webkit-text-stroke: 1px;
		-webkit-text-stroke-color: white;

		color: transparent;
		font-family: Kadwa, serif;
		min-width: max-content;
		background: linear-gradient(227deg, #f00 18.79%, #900 80.86%);
		-webkit-background-clip: text;
		background-clip: text;
	}

	h2 {
		font-size: 3rem;
		margin-bottom: 1rem;
		-webkit-text-stroke: 1px;
		-webkit-text-stroke-color: black;

		color: #ffd700;
		font-family: Kadwa, serif;
	}

	@keyframes breathe {
		0% {
			transform: scale(0.8);
		}
		35% {
			transform: scale(1.35);
		}
		75% {
			transform: scale(1);
		}
		100% {
			transform: scale(0.8);
		}
	}

	.text-content h2 {
		font-size: 3.5rem;
		color: #ffeb3b;
		min-height: 2rem;
	}

	.breathe {
		animation: breathe 0.75s infinite ease-in-out;
	}

	.scale-md {
		font-size: 3.75rem;
	}

	.scale-lg {
		font-size: 4rem;
	}

	.scale-xl {
		font-size: 4.25rem;
	}

	.scale-xxl {
		font-size: 4.5rem;
	}
</style>
