import jsdom from "jsdom"
const { JSDOM } = jsdom

export const getWebpageContents = async ({ url }: {url: string}): Promise<string> => {
    const dom = await JSDOM.fromURL(url)
    return dom.window.document.body.textContent?.replace(" ", "").replace("\n", "").replace("\t", "").replace("\r", "") || "Error: Could not get webpage contents"
}
