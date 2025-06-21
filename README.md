# Prodigy trial task - Scratcher

A scratch card script for FiveM

### Features

- Scratcher as a one-time use item

- Scratchers integrated with ox_inventory shops

- Configurable tier chances and prize values

- Custom UI Animations, sounds, and icon

- After win, character account balance updated with won amount

- Responsive UI matching provided design file

- Logging:

  - FiveM client user actions
  - Server Sided actions

### Config

Tiers are configurable via config.ts at `resources/[scratcher]/scratcher/web/config.ts`

!> [!WARNING]

> All 5 tiers need to be present

- `tier: number of connecting coins`
- `chance: percent to win that tier 5 = 5%`
- `prize: amount that will be transfered to account after winning`

Default config:

```ts
export const tiers: Tiers = [
  { chance: 0, prize: 0 }, // fallback value if nothing else is hit
  { chance: 5, prize: 500 }, // 5% chance 500$
  { chance: 0.1, prize: 1000 }, // 0.1% chance 1000$
  { chance: 0.005, prize: 100000 }, // 0.005% chance 100000$
  { chance: 0.00001, prize: 1000000 }, // 0.00001% chance 1000000$
];
```

## Stack

#### FiveM:

- ox_inventory
- ox_core
- MariaDB

### Front-end:

- Vue
- TypeScript

##### Copyright

- All sounds used came from ![Pixabay](https://pixabay.com/)

```

```
