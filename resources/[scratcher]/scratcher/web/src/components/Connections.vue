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

	function generateGrid(
		tiers: Props['tiers'],
		rows = 5,
		cols = 4,
	): { grid: (0 | 1)[][]; winningTier: Tier; connections: number } {
		const winnerIdx = rollWinner(tiers)
		const connections = winnerIdx + 1
		const placement = getPlacement(connections)
		const extraConnections = 4 // Math.max(0, Math.floor(Math.random() * 6) - (winnerIdx + 1))

		const grid = Array.from({ length: rows }, () => Array(cols).fill(0))

		let visited = new Set<string>()
		const dirs = [
			[0, 1],
			[1, 0],
			[0, -1],
			[-1, 0],
		]

		if (placement === 'column') {
			const col = Math.floor(Math.random() * grid[0].length)
			for (let r = 0; r < connections; r++) {
				grid[r][col] = 1
				visited.add(`${r}-${col}`)
			}
		}

		if (placement === 'row') {
			const row = Math.floor(Math.random() * grid.length)
			for (let c = 0; c < connections; c++) {
				grid[row][c] = 1
				visited.add(`${row}-${c}`)
			}
		}

		if (placement === 'crawler') {
			let r = Math.floor(Math.random() * rows)
			let c = Math.floor(Math.random() * cols)

			let placed = 0
			if (connections === 1) {
				grid[r][c] = 1
				placed++
			}

			while (placed < connections) {
				let r = Math.floor(Math.random() * rows)
				let c = Math.floor(Math.random() * cols)
				const randomDirs = [...dirs].sort(() => Math.random() - 0.5)

				for (const [dr, dc] of randomDirs) {
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
						for (let i = 0; i < connections; i++) {
							const nr = r + dr * i
							const nc = c + dc * i

							grid[nr][nc] = 1
							visited.add(`${nr}-${nc}`)
							placed++
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
			for (const [dr, dc] of dirs) {
				const nr = r + dr
				const nc = c + dc

				if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) continue
				if (grid[nr][nc] === 1) {
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
</script>

<template>
	<div class="wrapper">
		<div class="grid">
			<div
				v-for="row in result.grid.flatMap((row, r) =>
					row.map((active, c) => ({ active, r, c })),
				)"
				:key="`${row.r}-${row.c}`"
				class="cell"
			>
				<CoinSVG class="coin" :active="row.active === 1" />
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
		width: 90%;
		height: 90%;
		padding: 2rem;
		z-index: -2;
	}

	.grid {
		display: grid;
		grid-template-columns: repeat(4, minmax(0, 1fr));
		grid-template-rows: repeat(5, minmax(0, 1fr));
		gap: 0.7rem;
		place-items: center;
	}

	.glow-connection {
		width: 1rem;
		background: black;
	}
</style>
