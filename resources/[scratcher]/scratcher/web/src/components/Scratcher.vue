<script setup lang="ts">
	import CardBorderSVG from '../components/CardBorderSVG.vue'
	import Connections from '../components/Connections.vue'
	import ScratchSufrace from '../assets/scratcher/scratch-surface.png'
	import { ref, onMounted, nextTick } from 'vue'

	window.parent.postMessage({ action: 'close' }, '*')

	const svgRef = ref<SVGSVGElement | null>(null)
	const canvasRef = ref<HTMLCanvasElement | null>(null)

	const isScratching = ref<boolean>(false)

	onMounted(async () => {
		await nextTick()

		resizeCanvas()

		window.addEventListener('resize', resizeCanvas)

		const svgRoot = svgRef.value?.$el as SVGSVGElement | null
		if (!svgRoot) return

		const lightsGroup = svgRoot.querySelector('#lights')
		if (!lightsGroup) return

		const paths = lightsGroup.querySelectorAll('path')

		paths.forEach((path, i) => {
			setTimeout(() => {
				path.classList.add('animate-glow')
			}, i * 200)
		})

		const canvas = canvasRef.value
		if (!canvas) return
		const rect = canvas.getBoundingClientRect()
		canvas.width = rect.width
		canvas.height = rect.height
		const ctx = canvas.getContext('2d')
		if (!ctx) return

		const img = new Image()
		img.src = ScratchSufrace
		img.onload = () => {
			ctx.drawImage(img, 0, 0, canvas.width, canvas.height)
		}
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
	}

	function endScratch() {
		isScratching.value = false
	}

	function scratch(e: MouseEvent | TouchEvent) {
		e.preventDefault()
		if (!isScratching.value) return

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
		ctx.arc(x, y, 35, 0, Math.PI * 2)
		ctx.fill()
	}

	interface Tier {
		winAmount: number
		/** Percentage chance from 0 to 100 (inclusive) */
		chance: number
	}
	const tiers: [Tier, Tier, Tier, Tier, Tier] = [
		{ winAmount: 100, chance: 80 },
		{ winAmount: 200, chance: 60 },
		{ winAmount: 500, chance: 40 },
		{ winAmount: 1000, chance: 25 },
		{ winAmount: 5000, chance: 10 },
	]
</script>

<template>
	<div id="wrapper" class="background">
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
			<Connections :tiers="tiers" />
			<div class="canvas-background"></div>
		</div>
		<h2>WIN UP TO ${{ tiers[4].winAmount }}</h2>
	</div>
</template>

<style scoped>
	p {
		-webkit-text-stroke-width: 1.52px;
		-webkit-text-stroke-color: #fff;
		font-family: Kadwa, serif;
		width: max-content;
		font-size: 3.2rem;
		font-style: normal;
		font-weight: 700;
		line-height: 200.54%;
		text-transform: uppercase;
	}

	#glowing-wrapper {
		position: relative;
		pointer-events: none;
	}

	w-full {
		width: 100%;
	}

	#wrapper {
		padding: 4.25rem;
		position: relative;
		z-index: 1;
	}

	.canvas-background {
		position: absolute;
		width: calc(100% - 2.75rem);
		height: calc(100% - 3rem);
		inset: 1.53rem;
		z-index: -2;
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
		width: calc(100% - 2.75rem);
		height: calc(100% - 3rem);
		inset: 1.53rem;
		z-index: -1;
		pointer-events: auto;
	}

	.background {
		display: flex;
		flex-direction: column;
		border-radius: 1rem;
		gap: 6rem;
		text-align: center;
		background: radial-gradient(65.8% 73.84% at 49.74% 47.93%, #ffdc00 0%, #ff9600 100%), #fff;
	}

	@keyframes breathe {
		0% {
			opacity: 0;
		}
		20% {
			opacity: 1;
		}
		80% {
			opacity: 1;
		}
		100% {
			opacity: 0;
		}
	}

	:deep(.animate-glow) {
		animation: breathe 2.5s ease-in-out infinite;
	}
</style>
