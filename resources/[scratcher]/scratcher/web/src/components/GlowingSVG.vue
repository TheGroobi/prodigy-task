<template>
	<svg
		width="26"
		height="26"
		viewBox="0 0 26 26"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
		class="glow-ball"
	>
		<path
			d="M13.23 25.5601C20.244 25.5601 25.93 19.8741 25.93 12.86C25.93 5.84603 20.244 0.160034 13.23 0.160034C6.21596 0.160034 0.530029 5.84603 0.530029 12.86C0.530029 19.8741 6.21596 25.5601 13.23 25.5601Z"
			fill="url(#paint0_radial_1_250)"
		/>
		<defs>
			<radialGradient
				id="paint0_radial_1_250"
				cx="0"
				cy="0"
				r="1"
				gradientUnits="userSpaceOnUse"
				gradientTransform="translate(13.23 12.86) scale(12.7 12.7)"
			>
				<stop stop-color="white" />
				<stop offset="0.11" stop-color="#FFFFC7" />
				<stop offset="0.22" stop-color="#FFFF99" />
				<stop offset="0.3" stop-color="#FFFF7D" />
				<stop offset="0.34" stop-color="#FFFF73" />
				<stop offset="0.4" stop-color="#FFFF66" stop-opacity="0.89" />
				<stop offset="0.57" stop-color="#FFFF42" stop-opacity="0.58" />
				<stop offset="0.72" stop-color="#FFFF26" stop-opacity="0.33" />
				<stop offset="0.85" stop-color="#FFFF11" stop-opacity="0.15" />
				<stop offset="0.94" stop-color="#FFFF04" stop-opacity="0.04" />
				<stop offset="1" stop-color="#FFFF00" stop-opacity="0" />
			</radialGradient>
		</defs>
	</svg>
</template>

<style scoped>
	.glow-ball {
		transform: translate(-50%, -50%);
		position: absolute;
		pointer-events: none;
	}
</style>
