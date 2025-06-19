<script setup lang="ts">
	import stars from '../assets/scratcher/stars.svg'
	import CardBorderSVG from '../components/CardBorderSVG.vue'
	import Connections from '../components/Connections.vue'
	import ScratchSufrace from '../assets/scratcher/scratch-surface.png'
	import { ref, onMounted, nextTick } from 'vue'

	window.parent.postMessage({ action: 'close' }, '*')

	const svgRef = ref<SVGSVGElement | null>(null)
	const canvasRef = ref<HTMLCanvasElement | null>(null)

	const isScratching = ref<boolean>(false)

	const BRUSH_SIZE = 35 // <- this changes the radius of the brush

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
		const ctx = canvas?.getContext('2d')
		if (!ctx || !canvas) return

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
		ctx.arc(x, y, BRUSH_SIZE, 0, Math.PI * 2)
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
		{ winAmount: 50, chance: 10 },
	]
</script>

<template>
	<div id="wrapper" class="background">
		<img class="stars" :src="stars" />
		<img class="stars flipped" :src="stars" />
		<header>
			<h1 class="font-kadwa heading">scratch</h1>
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
			<Connections :tiers="tiers" />
			<div class="canvas-background"></div>
		</div>
		<h2 class="font-kadwa heading">win up to ${{ tiers[4].winAmount }}</h2>
	</div>
</template>

<style scoped>
	.stars {
		width: 7rem;
		position: absolute;
		top: 10px;
		right: 10px;
		&.flipped {
			left: 10px;
			-webkit-transform: scaleX(-1);
			transform: scaleX(-1);
		}
	}
	.heading {
		line-height: 1;
		-webkit-text-stroke-width: 1px;
		-webkit-text-stroke-color: #fff;
		font-family: Kadwa, serif;
		width: max-content;
		font-size: 3.2rem;
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
		font-size: 4.125rem;
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
	}

	.borderSVG {
		min-width: 22rem;
	}

	.canvas-background {
		position: absolute;
		inset: 1rem;
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
