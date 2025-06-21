import axios from 'axios'
export function nuiCallback({
	link,
	data = {},
	message = '',
}: {
	link: string
	data?: Record<string, any>
	message?: string
}) {
	//@ts-expect-error
	const url = `https://${GetParentResourceName()}/`

	if (message) {
		console.log(message)
	}

	try {
		axios.post(url + link, data)
	} catch (e) {
		console.error(e)
	}
}
