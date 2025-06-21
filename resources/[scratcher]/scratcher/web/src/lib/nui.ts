import axios from 'axios'
import { sendDiscordLog } from './log'
export function nuiCallback({
	link,
	data = {},
}: {
	link: string
	data?: Record<string, any>
	message?: string
}) {
	//@ts-expect-error
	const url = `https://${GetParentResourceName()}/`

	try {
		axios.post(url + link, data)
	} catch (e) {
		sendDiscordLog({
			method: 'error',
			ownerId: -1,
			title: 'Axios error',
			message: String(e),
			at: 'nui.ts',
		})
	}
}
