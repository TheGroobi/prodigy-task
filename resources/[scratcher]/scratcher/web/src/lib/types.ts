export interface Tier {
	chance: number
	prize: number
}

export type Tiers = [Tier, Tier, Tier, Tier, Tier] // always 5 of them
