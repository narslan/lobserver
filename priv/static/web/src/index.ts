import { Route, Router } from '@vaadin/router';
import './main-layout';

const routes: Route[] = [
	{
		path: '/',
		component: 'main-layout',
		children: [
	
			{
				path: 'home',
				component: 'home-element',
				action: async () => {
					await import('./views/home');
				},
       
			}



		],
	},
];

const outlet = document.getElementById('outlet');
export const router = new Router(outlet);
router.setRoutes(routes);
