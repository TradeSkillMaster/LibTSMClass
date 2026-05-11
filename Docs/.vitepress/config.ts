import { defineConfig } from "vitepress"

export default defineConfig({
	title: "LibTSMClass",
	description: "OOP class library for World of Warcraft addons",
	themeConfig: {
		nav: [
			{ text: "Home", link: "/" },
		],
		sidebar: [
			{
				items: [
					{ text: "Home", link: "/" },
					{ text: "Features", link: "/features" },
					{ text: "Notes", link: "/notes" },
					{ text: "API", link: "/api" },
				],
			},
		],
	},
})
