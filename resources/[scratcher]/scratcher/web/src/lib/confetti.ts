const defaults = {
	spread: 400,
	ticks: 100,
	gravity: 1,
	decay: 0.92,
	startVelocity: 40,
}

export function shoot() {
	confetti({
		...defaults,
		particleCount: 50,
		scalar: 1.5,
		shapes: ['circle', 'square'],
		colors: ['#a864fd', '#29cdff', '#78ff44', '#ff718d', '#fdff6a'],
	})

	confetti({
		...defaults,
		particleCount: 100,
		scalar: 3,
		shapes: ['emoji'],
		shapeOptions: {
			emoji: {
				value: ['💲', '💸'],
			},
		},
	})
}
