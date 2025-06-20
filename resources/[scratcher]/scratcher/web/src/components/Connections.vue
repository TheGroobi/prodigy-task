<script setup lang="ts">
	import CoinSVG from './CoinSVG.vue'

	interface Tier {
		winAmount: number
		chance: number
	}

	interface Props {
		tiers: [Tier, Tier, Tier, Tier, Tier] // base of 5 tiers - max connections of 5
	}

	const props = defineProps<Props>()

	function rollWinner(tiers: Props['tiers']): number {
		const total = tiers.reduce((sum, tier) => sum + tier.chance, 0)
		if (total === 0) return 0

		const rand = Math.random()
		let sum = 0

		for (let i = tiers.length - 1; i >= 0; i--) {
			sum += tiers[i].chance / total
			if (rand < sum) return i
		}

		return 0
	}

	function getPlacement(connections: number): 'column' | 'row' | 'crawler' {
		if (connections === 5) return 'column'
		if (connections === 4) return Math.random() * 0.5 ? 'row' : 'column'
		return 'crawler'
	}

	function isInvalid(
		COLS: number,
		ROWS: number,
		r: number,
		c: number,
		grid: number[][],
		visited = new Set<string>(),
	): boolean {
		return (
			r < 0 || r >= ROWS || c < 0 || c >= COLS || grid[r][c] === 1 || visited.has(`${r}-${c}`)
		)
	}

	let direction: 'left' | 'right' | 'top' | 'bottom'
	let startCell: [number, number]
	let endCell: [number, number]
	function generateGrid(
		tiers: Props['tiers'],
		rows = 5,
		cols = 4,
	): { grid: (0 | 1 | 2)[][]; winningTier: Tier; connections: number } {
		const winnerIdx = rollWinner(tiers)
		const connections = winnerIdx + 1
		const placement = getPlacement(connections)
		const extraConnections = 4 // Math.max(0, Math.floor(Math.random() * 6) - (winnerIdx + 1))

		const grid = Array.from({ length: rows }, () => Array(cols).fill(0))

		let visited = new Set<string>()
		const dirs: Record<typeof direction, number[]> = {
			right: [0, 1],
			top: [1, 0],
			left: [0, -1],
			bottom: [-1, 0],
		}

		if (placement === 'column') {
			const col = Math.floor(Math.random() * grid[0].length)
			startCell = [0, col]
			endCell = [connections - 1, col]
			for (let r = 0; r < connections; r++) {
				grid[r][col] = 1
				visited.add(`${r}-${col}`)
			}
			direction = 'bottom'
		}

		if (placement === 'row') {
			const row = Math.floor(Math.random() * grid.length)
			startCell = [row, 0]
			endCell = [row, connections - 1]

			for (let c = 0; c < connections; c++) {
				grid[row][c] = 1
				visited.add(`${row}-${c}`)
			}

			direction = 'right'
		}

		if (placement === 'crawler') {
			let r = Math.floor(Math.random() * rows)
			let c = Math.floor(Math.random() * cols)

			let placed = 0
			if (connections === 1) {
				grid[r][c] = 2
				placed++
			}

			while (placed < connections) {
				let r = Math.floor(Math.random() * rows)
				let c = Math.floor(Math.random() * cols)
				const randomDirs = Object.entries(dirs).sort(() => Math.random() - 0.5)

				for (const [dirName, [dr, dc]] of randomDirs) {
					let valid = true

					if (r + dr * connections >= rows || c + dc * connections >= cols) {
						continue
					}

					for (let i = 0; i < connections; i++) {
						const nr = r + dr * i
						const nc = c + dc * i

						if (isInvalid(rows, cols, nr, nc, grid, visited)) {
							valid = false
							break
						}
					}

					if (valid) {
						startCell = [r, c]
						direction = dirName as typeof direction
						console.log(direction, [dr, dc])

						for (let i = 0; i < connections; i++) {
							const nr = r + dr * i
							const nc = c + dc * i

							grid[nr][nc] = 2
							visited.add(`${nr}-${nc}`)
							placed++
							endCell = [nr, nc]
						}

						break
					}
				}
			}
		}

		let extraPlaced = 0
		let attempts = 0

		while (extraPlaced < extraConnections && attempts < 100) {
			attempts++
			let r = Math.floor(Math.random() * rows)
			let c = Math.floor(Math.random() * cols)

			if (isInvalid(cols, rows, r, c, grid, visited)) continue

			let valid = true
			for (const [dr, dc] of Object.values(dirs)) {
				const nr = r + dr
				const nc = c + dc

				if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) continue
				if (grid[nr][nc]) {
					valid = false
					break
				}
			}

			if (valid) {
				grid[r][c] = 1
				visited.add(`${r}-${c}`)
				extraPlaced++
			}
		}

		return { grid, winningTier: tiers[winnerIdx], connections }
	}

	const result = generateGrid(
		props?.tiers ?? [
			{ winAmount: 100, chance: 10 },
			{ winAmount: 200, chance: 5 },
			{ winAmount: 500, chance: 0.1 },
			{ winAmount: 1000, chance: 0.05 },
			{ winAmount: 5000, chance: 0.0001 },
		],
	)

	console.log(result.grid)
	console.log(result.connections)
	console.log(result.winningTier)

	function isStart(r: number, c: number) {
		if (startCell) {
			return r === startCell[0] && c === startCell[1]
		} else {
			false
		}
	}

	function isEnd(r: number, c: number) {
		if (endCell) {
			return r === endCell[0] && c === endCell[1]
		} else {
			false
		}
	}
</script>

<template>
	<div class="wrapper">
		<div class="grid">
			<div
				v-for="row in result.grid.flatMap((row, r) => row.map((val, c) => ({ val, r, c })))"
				:class="[
					'coin-wrapper',
					row.val === 2 && result.connections !== 1 ? 'glow' : '',
					row.val === 2 && isStart(row.r, row.c) ? 'glow-start' : '',
					row.val === 2 && isEnd(row.r, row.c) ? 'glow-end' : '',
					direction,
				]"
				:key="`${row.r}-${row.c}`"
			>
				<CoinSVG :active="Boolean(row.val)" class="coin" />
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
		padding: 2.5rem 2.5rem 3rem 2.5rem;
		z-index: -2;
		display: grid;
		place-items: center;
	}

	.grid {
		display: grid;
		grid-template-columns: repeat(4, minmax(0, 1fr));
		grid-template-rows: repeat(5, minmax(0, 1fr));
		place-items: center;
	}
	.coin-wrapper {
		height: calc(90px + 0.5rem);
		padding: 0.25rem;
		position: relative;
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
