import type { LogMsg } from '@/lib/types'
import axios from 'axios'

const colors: Record<LogMsg['method'], number> = {
	action: 0x00ff00, // green
	warn: 0xffff00, // yellow
	info: 0x3498db, // blue
	error: 0xff0000, // red
}

export async function sendDiscordLog({ ownerId, method, message, at, title }: LogMsg) {
	const payload = {
		content: null,
		embeds: [
			{
				author: {
					name: `[${method.toUpperCase()}]`,
				},
				title: method === 'error' ? title : `User with id: **${ownerId}**`,
				description: message,
				color: colors[method],
				footer: {
					text: `[scratcher] - ${at}`,
				},
				timestamp: new Date().toISOString(),
			},
		],
		attachments: [],
	}

	await post(payload)
}

export async function sendTestingLog({
	title,
	description,
	at,
}: {
	title: string
	description: string
	at: string
}) {
	const payload = {
		content: null,
		embeds: [
			{
				author: {
					name: `[TEST]`,
				},
				title,
				description,
				color: 0x5865f2,
				footer: {
					text: `[scratcher] - ${at}`,
				},
				timestamp: new Date().toISOString(),
			},
		],
		attachments: [],
	}

	await post(payload)
}

async function post(payload: any) {
	const webhook = import.meta.env.VITE_DISCORD_WEBHOOK_URL

	if (!webhook) {
		console.warn('[Discord] Webhook URL is not set')
		return
	}

	try {
		await axios.post(webhook, payload, {
			headers: {
				'Content-Type': 'application/json',
			},
		})
	} catch (err) {
		console.error('[Discord Log] Failed to send webhook:', err)
	}
}

export function formatMatrix(matrix: number[][]): string {
	return matrix.map((row) => row.join('  ')).join('\n')
}
