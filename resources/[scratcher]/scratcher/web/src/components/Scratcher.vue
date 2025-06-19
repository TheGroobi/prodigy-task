<script setup lang="ts">
	//import cardOver from '../assets/scratcher/card-over.png'
	import GlowingSVG from '../components/GlowingSVG.vue'
	import EmptySVG from '../components/EmptySVG.vue'
	import { ref, onMounted, nextTick } from 'vue'

	const svgRef = ref<SVGSVGElement | null>(null)

	const glowingBalls = ref<{ x: number; y: number; animate?: boolean }[]>([])

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
		addGlowingBalls(svg)

		await nextTick()
		glowingBalls.value.forEach((ball, i) => {
			setTimeout(() => {
				ball.animate = true
			}, i * 35)
		})
	})

	let size: number = 300
	let prize: number = 100000
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
		</div>
		<figure>
			<canvas :width="size" :height="Math.floor(size * 1.1125)" class="box"></canvas>
			<figcaption class="w-full">
				<svg viewBox="0 0 471 100" width="100%" xmlns="http://www.w3.org/2000/svg">
					<defs>
						<linearGradient id="grad">
							<stop offset="0%" stop-color="#ff0000" />
							<stop offset="91%" stop-color="#990000" />
						</linearGradient>
					</defs>
					<text
						x="0"
						y="70"
						font-family="'Kadwa', serif"
						font-size="48"
						font-weight="700"
						fill="url(#grad)"
						stroke="#fff"
						stroke-width="2"
						paint-order="stroke fill"
						dominant-baseline="middle"
					>
						WIN UP TO ${{ prize }}
					</text>
				</svg>
			</figcaption>
		</figure>
	</div>
</template>

<style scoped>
	#glowing-wrapper {
		position: relative;
	}

	w-full {
		width: 100%;
	}

	#wrapper {
		width: calc(481px + 8.5rem);
		padding: 4.25rem;
		img {
			pointer-events: none;
		}
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
