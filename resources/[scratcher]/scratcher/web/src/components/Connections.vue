<script setup lang="ts">
	interface Tier {
		winAmount: number

		/** Percentage chance from 0 to 100 (inclusive) */
		chance: number
	}

	interface Props {
		tiers: [Tier, Tier, Tier, Tier, Tier] // base of 5 tiers - max connections of 5
	}

	const props = defineProps<Props>()

	function rollWinner(tiers: Props['tiers']): number {
		const total = tiers.reduce((sum, tier) => sum + tier.chance, 0)
		const rand = Math.random() * total

		let sum = 0
		for (let i = 0; i < tiers.length; i++) {
			sum += tiers[i].chance
			if (rand < sum) return i
		}

		return 0
	}

	function getPlacement(connections: number): 'column' | 'row' | 'crawler' {
		if (connections === 5) return 'column'
		if (connections === 4) return Math.random() * 0.5 ? 'row' : 'column'
		return 'crawler'
	}

	function generateGrid(
		tiers: Props['tiers'],
		rows = 5,
		cols = 4,
	): { grid: (0 | 1)[][]; winningTier: Tier } {
		const winnerIdx = rollWinner(tiers)
		const connections = winnerIdx + 1
		const placement = getPlacement(connections)
		const extraConnections = Math.max(0, Math.floor(Math.random() * 6) - (winnerIdx + 1))

		const grid = Array.from({ length: rows }, () => Array(cols).fill(0))

		const visited = new Set<string>()
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
			grid[r][c] = 1
			visited.add(`${r}-${c}`)

			let placed = 1

			while (placed < connections) {
				const randomDirs = [...dirs].sort(() => Math.random() - 0.5)
				let moved = false

				// choose one direction and follow it until connections end
				for (const [dr, dc] of randomDirs) {
					const nr = r + dr
					const nc = c + dc
					if (
						nr >= 0 &&
						nr < rows &&
						nc >= 0 &&
						nc < cols &&
						grid[nr][nc] === 0 &&
						!visited.has(`${nr}-${nc}`)
					) {
						grid[nr][nc] = 1
						visited.add(`${nr}-${nc}`)

						r = nr
						c = nc

						placed++
						moved = true
						break
					}

					if (!moved) break // stuck
				}
			}
		}

		return { grid, winningTier: tiers[winnerIdx] }
	}

	const result = generateGrid(
		props.tiers ?? [
			{ winAmount: 100, chance: 60 },
			{ winAmount: 200, chance: 25 },
			{ winAmount: 500, chance: 10 },
			{ winAmount: 1000, chance: 4 },
			{ winAmount: 5000, chance: 1 },
		],
	)

	console.log(result.grid)
	console.log('Winner Tier:', result.winningTier)
</script>

<template>
	<div></div>
</template>
