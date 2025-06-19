<script setup lang="ts">
	import GlowingSVG from '../components/GlowingSVG.vue'
	import EmptySVG from '../components/EmptySVG.vue'
	import ScratchSufrace from '../assets/scratcher/scratch-surface.png'
	import { ref, onMounted, nextTick } from 'vue'

	const svgRef = ref<SVGSVGElement | null>(null)
	const canvasRef = ref<HTMLCanvasElement | null>(null)

	const glowingBalls = ref<{ x: number; y: number; animate?: boolean }[]>([])
	const isScratching = ref<boolean>(false)

	const SIZE: number = 300
	const PRIZE = 100000

	function addGlowingBalls(svg: SVGSVGElement, groupSelector = '#balls path') {
		const paths = svg.querySelectorAll(groupSelector) as NodeListOf<SVGPathElement>
		const wrapper = svg.closest('#glowing-wrapper')!
		const wrapperRect = wrapper.getBoundingClientRect()

		paths.forEach((path) => {
			const bbox = path.getBBox()
			const centerX = bbox.x + bbox.width / 2
			const centerY = bbox.y + bbox.height / 2

			// Convert SVG point to screen coords
			const pt = svg.createSVGPoint()
			pt.x = centerX
			pt.y = centerY
			const screenPt = pt.matrixTransform(svg.getScreenCTM()!)

			const relativeX = screenPt.x - wrapperRect.left
			const relativeY = screenPt.y - wrapperRect.top

			glowingBalls.value.push({ x: relativeX, y: relativeY })
		})
	}

	onMounted(async () => {
		await nextTick()

		const svg = svgRef.value?.$el ?? svgRef.value
		if (svg) addGlowingBalls(svg)

		glowingBalls.value.forEach((ball, i) => {
			setTimeout(() => {
				ball.animate = true
			}, i * 35)
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
		ctx.arc(x, y, 50, 0, Math.PI * 2)
		ctx.fill()
	}
</script>

<template>
	<div id="wrapper" class="background">
		<div id="glowing-wrapper" class="relative">
			<EmptySVG ref="svgRef" />
			<GlowingSVG
				v-for="(pt, i) in glowingBalls"
				:key="i"
				:class="{ 'animate-glow': pt.animate }"
				:style="{
					visibility: i % 2 ? 'hidden' : 'visible',
					opacity: 0,
					left: `${pt.x}px`,
					top: `${pt.y}px`,
				}"
			/>
			<canvas
				ref="canvasRef"
				@mousemove="scratch"
				@touchstart="startScratch"
				@touchend="endScratch"
				@mousedown="startScratch"
				@mouseup="endScratch"
				class="canvas"
			></canvas>
		</div>
		<p class="font-kadwa">WIN UP TO ${{ PRIZE }}</p>
	</div>
</template>

<style scoped>
	p {
		leading-trim: both;
		text-edge: cap;
		-webkit-text-stroke-width: 1.52px;
		-webkit-text-stroke-color: #fff;
		font-family: Kadwa, serif;
		width: max-content;
		font-size: 3.2rem;
		font-style: normal;
		font-weight: 700;
		line-height: 200.54%; /* 6.09794rem */
		text-transform: uppercase;
	}
	#glowing-wrapper {
		position: relative;
	}

	w-full {
		width: 100%;
	}

	#wrapper {
		padding: 4.25rem;
		position: relative;
		img {
			pointer-events: none;
		}
	}

	.canvas {
		&:hover {
			cursor: crosshair;
		}
		z-index: -1;
		touch-action: none;
		position: absolute;
		top: 0;
		border-radius: 0.9rem;
		left: 0;
		width: calc(100% - 3.86rem);
		height: calc(100% - 4.3rem);
		z-index: 1;
		inset: 1.93rem;
	}

	/*
		.box {
			height: 100%;
			width: 100%;
			position: absolute;
			top: 0;
			left: 0;
		}
		.overlay {
			z-index: 1;
		}
		   */

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

	.animate-glow {
		animation: breathe 2.2s ease-in-out infinite;
	}
</style>
