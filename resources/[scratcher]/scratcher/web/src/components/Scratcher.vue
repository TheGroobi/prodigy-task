<script setup lang="ts">
	import stars from '../assets/scratcher/stars.png'
	import CardBorderSVG from '../components/CardBorderSVG.vue'
	import MegaBigWin from './MegaBigWin.vue'
	import MegaBigLose from './MegaBigLose.vue'
	import Connections from '../components/Connections.vue'
	import ScratchSufrace from '../assets/scratcher/scratch-surface.png'
	import { ref, onMounted, nextTick, watch } from 'vue'
	import { shoot } from '@/lib/confetti'
	import { nuiCallback } from '@/lib/nui'
	import winSound from '../assets/scratcher/win-sound.ogg'
	import loseSound from '../assets/scratcher/lose-sound.ogg'
	import { tiers } from '../../config'
	import type { Tier } from '@/lib/types'

	window.parent.postMessage({ action: 'close' }, '*')

	const svgRef = ref<SVGSVGElement | null>(null)
	const canvasRef = ref<HTMLCanvasElement | null>(null)
	const audioRef = ref<HTMLAudioElement | null>(null)

	const BRUSH_SIZE = 35 // <- this changes the radius of the brush

	const isScratching = ref<boolean>(false)
	let hasWon = ref<boolean | null>(null)
	let scratched = ref<boolean>(false)
	let mounted = ref<boolean>(false)
	let soundSrc = ref<string>('')

	onMounted(async () => {
		await nextTick()

		resizeCanvas()

		window.addEventListener('resize', resizeCanvas)

		//@ts-expect-error
		const svgRoot = svgRef.value?.$el as SVGSVGElement | null
		if (!svgRoot) return

		const lightsGroup = svgRoot.querySelector('#lights')
		if (!lightsGroup) return

		const paths = lightsGroup.querySelectorAll('path')

		paths.forEach((path, i) => {
			setTimeout(() => {
				path.classList.add('animate-glow')
			}, i * 75)
		})

		const canvas = canvasRef.value
		const ctx = canvas?.getContext('2d')
		if (!ctx || !canvas) return

		const img = new Image()
		img.src = ScratchSufrace
		img.onload = () => {
			ctx.drawImage(img, 0, 0, canvas.width, canvas.height)
		}
		await nextTick()
		setTimeout(() => {
			mounted.value = true
		}, 150)
	})

	function resizeCanvas() {
		const canvas = canvasRef.value
		if (!canvas) return

		const rect = canvas.getBoundingClientRect()
		canvas.width = rect.width
		canvas.height = rect.height
	}

	function startScratch() {
		isScratching.value = true

		if (!scratched.value) {
			console.log('Started scratching')
			scratched.value = true
			nuiCallback({ link: 'scratcher:consume', message: 'Consuming scratcher' })
		}
	}

	function endScratch() {
		isScratching.value = false
	}

	const seenCoins = ref<Set<string>>(new Set())
	function scratch(e: MouseEvent | TouchEvent) {
		e.preventDefault()
		if (!isScratching.value) return

		if (!scratched.value) {
			console.log('Started scratching')
			scratched.value = true
			nuiCallback({
				link: 'scratcher:consume',
				message: 'Consuming scratcher',
			})
		}

		const canvas = canvasRef.value
		if (!canvas) return
		const ctx = canvas.getContext('2d')
		if (!ctx) return

		const rect = canvas.getBoundingClientRect()
		let x: number, y: number

		if (e instanceof TouchEvent) {
			const touch = e.touches[0]
			x = touch.clientX - rect.left
			y = touch.clientY - rect.top
		} else {
			x = e.clientX - rect.left
			y = e.clientY - rect.top
		}

		ctx.globalCompositeOperation = 'destination-out'
		ctx.lineJoin = 'round'
		ctx.lineCap = 'round'
		ctx.lineWidth = 40
		ctx.beginPath()
		ctx.arc(x, y, BRUSH_SIZE, 0, Math.PI * 2)
		ctx.fill()

		const coinEls = document.querySelectorAll('.coin-wrapper')
		coinEls.forEach((el, index) => {
			const box = el.getBoundingClientRect()
			const cx = box.left + box.width / 2
			const cy = box.top + box.height / 2

			const dist = Math.sqrt((x + rect.left - cx) ** 2 + (y + rect.top - cy) ** 2)

			if (dist < BRUSH_SIZE) {
				const r = Math.floor(index / 4) // <- hard coded 4 columns
				const c = index % 4
				if (!seenCoins.value.has(`${r}-${c}`)) {
					seenCoins.value.add(`${r}-${c}`)
				}
			}
		})
	}

	function rollWinner(t: typeof tiers): number {
		const total = t.reduce((sum, tier) => sum + tier.chance, 0)
		if (total === 0) return 0

		const rand = parseFloat((Math.random() * 100).toFixed(6))

		let sum = 0
		for (let i = 0; i < t.length; i++) {
			sum += t[i].chance
			if (rand < sum) return i
		}

		return 0 // fallback to tier 0 - nothing won
	}

	/* This is for testing odds of different tiers
     *
	const winners = new Array(tiers.length).fill(0)
	for (let i = 0; i < 1_000_000; i++) {
		winners[rollWinner(tiers)]++
	}
	console.log('1 mil random rolls :', winners)

    */

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
	let winning = ref<string[]>([])
	function generateGrid(
		t: typeof tiers,
		rows = 5,
		cols = 4,
	): { grid: (0 | 1 | 2)[][]; winningTier: Tier; connections: number } {
		const winnerIdx = rollWinner(t)
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
				grid[r][col] = 2
				visited.add(`${r}-${col}`)
				winning.value.push(`${r}-${col}`)
			}
			direction = 'bottom'
		}

		if (placement === 'row') {
			const row = Math.floor(Math.random() * grid.length)
			startCell = [row, 0]
			endCell = [row, connections - 1]

			for (let c = 0; c < connections; c++) {
				grid[row][c] = 2
				visited.add(`${row}-${c}`)
				winning.value.push(`${row}-${c}`)
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

						for (let i = 0; i < connections; i++) {
							const nr = r + dr * i
							const nc = c + dc * i

							grid[nr][nc] = 2
							visited.add(`${nr}-${nc}`)
							winning.value.push(`${nr}-${nc}`)
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

		return { grid, winningTier: t[winnerIdx], connections }
	}

	const ROWS = 5
	const COLS = 4
	const result = generateGrid(tiers, ROWS, COLS)
	console.log('Connections this scratcher: ', result.connections)

	function playSound(sound: 'win' | 'lose' | 'scratch') {
		switch (sound) {
			case 'win':
				soundSrc.value = winSound
				break
			/* TODO
			case 'scratch':
				soundSrc.value = winSound
				break
            */
			case 'lose':
				soundSrc.value = loseSound
				break
		}

		nextTick(() => {
			audioRef.value?.play()
		})
	}
	watch(
		() => seenCoins.value.size,
		() => {
			if (hasWon.value !== null || !scratched || seenCoins.value.size !== ROWS * COLS) return

			const winningRevealed = winning.value.every((cell) => seenCoins.value.has(cell))

			if (winningRevealed && result.connections !== 1) {
				setTimeout(() => {
					hasWon.value = true
				}, 2000)
			} else {
				setTimeout(() => {
					hasWon.value = false
				}, 2000)
			}
		},
	)

	watch(hasWon, () => {
		if (hasWon.value === true) {
			shoot()
			playSound('win')
			setTimeout(() => {
				nuiCallback({
					link: 'scratcher:win',
					data: { prize: result.winningTier.prize },
					message: `User has won: $${result.winningTier.prize} \nat chance ${result.winningTier.chance}%`,
				})
			}, 1000)
		} else if (hasWon.value === false) {
			playSound('lose')
			setTimeout(() => {
				nuiCallback({
					link: 'scratcher:lose',
					message: `User did not win anything`,
				})
			}, 1000)
		}
	})
</script>

<template>
	<div id="wrapper" class="background">
		<MegaBigWin :prize="result.winningTier.prize" v-if="hasWon === true" />
		<MegaBigLose v-else-if="hasWon === false" />

		<img class="stars" :src="stars" />
		<img class="stars flipped" :src="stars" />
		<header>
			<h1 class="font-kadwa heading font--64">scratch</h1>
			<h1 class="font-kadwa font--38 heading">& win</h1>
		</header>
		<div id="glowing-wrapper" class="relative">
			<CardBorderSVG class="borderSVG" ref="svgRef" />
			<canvas
				ref="canvasRef"
				@mousemove="scratch"
				@touchstart="startScratch"
				@touchend="endScratch"
				@mousedown="startScratch"
				@mouseup="endScratch"
				class="canvas"
			></canvas>
			<Connections
				v-if="mounted === true"
				:grid="result.grid"
				:startCell="startCell"
				:endCell="endCell"
				:direction="direction"
				:connections="result.connections"
			/>
			<div class="canvas-background"></div>
		</div>
		<h2 class="font-kadwa heading">win up to ${{ tiers[4].prize }}</h2>
		<audio v-if="soundSrc" :src="soundSrc" ref="audioRef" hidden></audio>
	</div>
</template>

<style scoped>
	.stars {
		width: 8.5rem;
		position: absolute;
		top: 1rem;
		right: 1rem;
		&.flipped {
			left: 1rem;
			-webkit-transform: scaleX(-1);
			transform: scaleX(-1);
		}
	}
	.heading {
		line-height: 1;
		-webkit-text-stroke-width: 1.5px;
		-webkit-text-stroke-color: #fff;
		font-family: Kadwa, serif;
		width: max-content;
		font-size: 3.1rem;
		font-style: normal;
		font-weight: 700;
		text-transform: uppercase;
		text-align: center;
		width: 100%;
	}

	header h1 {
		background: linear-gradient(97deg, #f00 18.79%, #900 80.86%);
		-webkit-background-clip: text;
		background-clip: text;
		color: transparent;
	}

	.font--64 {
		font-size: 4rem;
		line-height: 1;
	}

	.font--38 {
		font-size: 2.4rem;
		-webkit-text-stroke-width: 0.75px;
		line-height: 1;
	}

	#glowing-wrapper {
		position: relative;
		pointer-events: none;
		margin-top: 2.5rem;
		margin-bottom: 4.5rem;
	}

	w-full {
		width: 100%;
	}

	#wrapper {
		padding-top: 3.75rem;
		padding-bottom: 4.5rem;
		padding-right: 3.25rem;
		padding-left: 3.25rem;
		position: relative;
		z-index: 1;
		box-shadow:
			0 4px 8px 0 rgba(0, 0, 0, 0.2),
			0 6px 20px 0 rgba(0, 0, 0, 0.19);
	}

	.borderSVG {
		min-width: 16rem;
	}

	.canvas-background {
		position: absolute;
		inset: 1rem;
		z-index: -3;
		border-radius: 0.9rem;
		background-color: hsla(5, 100%, 17%, 1);

		overflow: hidden;
	}

	.canvas-background::after {
		content: '';
		opacity: 0.35;
		position: absolute;
		inset: 0;
		border-radius: inherit;
		background: radial-gradient(47.51% 52.94% at 50% 50%, #e1563c 0%, #bd223e 100%);
		mix-blend-mode: normal;
		pointer-events: none;
	}
	.canvas {
		&:hover {
			cursor: crosshair;
		}
		touch-action: none;
		position: absolute;
		top: 0;
		border-radius: 0.9rem;
		left: 0;
		width: calc(100% - 2rem);
		height: calc(100% - 2rem);
		inset: 1rem;
		z-index: -1;
		pointer-events: auto;
	}

	.background {
		display: flex;
		flex-direction: column;
		border-radius: 1rem;
		text-align: center;
		background: radial-gradient(65.8% 73.84% at 49.74% 47.93%, #ffdc00 0%, #ff9600 100%), #fff;
		background-size: cover;
		background-repeat: no-repeat;
		background-position: center center;
		background-image: url('../assets/scratcher/background.png');
	}

	@keyframes breathe {
		0% {
			opacity: 1;
		}
		40% {
			opacity: 0;
		}
		60% {
			opacity: 0;
		}
		100% {
			opacity: 1;
		}
	}

	:deep(.animate-glow) {
		animation: breathe 1.2s ease-in-out infinite;
	}
</style>
