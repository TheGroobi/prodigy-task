<script setup lang="ts">
	import CoinSVG from './CoinSVG.vue'

	interface Props {
		grid: (0 | 1 | 2)[][]
		seen: Set<string> // or boolean[][] if you prefer
		connections: number
		startCell?: [number, number]
		endCell?: [number, number]
		direction?: 'top' | 'bottom' | 'left' | 'right'
	}

	const { grid, seen, connections, startCell, endCell, direction } = defineProps<Props>()

	function isStart(r: number, c: number) {
		return startCell ? r === startCell[0] && c === startCell[1] : false
	}

	function isEnd(r: number, c: number) {
		return endCell ? r === endCell[0] && c === endCell[1] : false
	}
</script>

<template>
	<div class="wrapper">
		<div class="container">
			<div
				v-for="{ val, c, r } in grid.flatMap((row, r) =>
					row.map((val, c) => ({ val, r, c })),
				)"
				:class="[
					'coin-wrapper',
					val === 2 && connections !== 1 ? 'glow' : '',
					val === 2 && isStart(r, c) ? 'glow-start' : '',
					val === 2 && isEnd(r, c) ? 'glow-end' : '',
					direction,
				]"
				:key="`${r}-${c}`"
			>
				<CoinSVG :active="Boolean(val)" class="coin" />
			</div>
		</div>
	</div>
</template>

<style scoped>
	.wrapper {
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		width: 100%;
		height: 100%;
		z-index: -2;
		display: grid;
		place-items: center;
	}

	.container {
		display: grid;
		grid-template-columns: repeat(4, minmax(0, 1fr));
		grid-template-rows: repeat(5, minmax(0, 1fr));

		padding: 2.5rem;
		position: relative;
	}

	.row {
		display: flex;
		flex-direction: row;
		flex: 1;
	}

	.coin-wrapper {
		position: relative;
		padding: 0.25rem;
		max-width: 80px;
	}

	:deep(.glow::before) {
		content: '';
		position: absolute;
		inset: 0;
		z-index: 0;
		border-radius: inherit;

		background: linear-gradient(
			0deg,
			rgba(255, 220, 0, 0.24) 15.98%,
			rgba(255, 231, 35, 0.24) 22.91%,
			rgba(255, 244, 74, 0.24) 31.38%,
			rgba(255, 252, 98, 0.24) 37.55%,
			rgba(255, 255, 107, 0.24) 42.17%,
			rgba(255, 220, 0, 0.24) 68.36%,
			rgba(255, 165, 0, 0.24) 93.01%
		);
		filter: blur(5px);
		pointer-events: none;
		animation: pulse 2s ease-in-out infinite;
		transform-origin: center;
	}

	@keyframes pulse {
		0% {
			opacity: 0.75;
			transform: scale(1);
		}
		50% {
			opacity: 0.9;
			transform: scale(1.1);
		}
		100% {
			opacity: 0.75;
			transform: scale(1);
		}
	}

	.glow-start,
	.glow-end {
		border-radius: 0;
	}

	/* === HORIZONTAL === */
	.glow-start.right,
	.glow-end.left {
		border-radius: 50% 0 0 50%;
	}

	.glow-end.right,
	.glow-start.left {
		border-radius: 0 50% 50% 0;
	}

	.glow-end.bottom,
	.glow-start.top {
		border-radius: 50% 50% 0 0;
	}

	.glow-start.bottom,
	.glow-end.top {
		border-radius: 0 0 50% 50%;
	}
</style>
