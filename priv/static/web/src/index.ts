import { Route, Router } from "@vaadin/router";
import "./main-layout";

const routes: Route[] = [
	{
		path: "/",
		component: "main-layout",
		children: [
			{ path: "", redirect: "/metrics" },
			{
				path: "home",
				component: "home-element",
				action: async () => {
					await import("./views/home");
				},
			},
			{
				path: "metrics",
				component: "metrics-element",
				action: async () => {
					await import("./views/metrics-element");
				},
			},
		],
	},
];

const outlet = document.getElementById("outlet");
export const router = new Router(outlet);
router.setRoutes(routes);
