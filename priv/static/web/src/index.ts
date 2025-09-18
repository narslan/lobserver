import { Route, Router } from "@vaadin/router";
import "./main-layout";

const routes: Route[] = [
	{
		path: "/",
		component: "main-layout",
		children: [
			{ path: "", redirect: "/rabbit" },
			{
				path: "home",
				component: "home-element",
				action: async () => {
					await import("./views/home");
				},
			},
			{
				path: "rabbit",
				component: "white-rabbit-element",
				action: async () => {
					await import("./views/white-rabbit");
				},
			},
		],
	},
];

const outlet = document.getElementById("outlet");
export const router = new Router(outlet);
router.setRoutes(routes);
