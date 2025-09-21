# lobserver

`lobserver` is an Elixir layout to create web dashboards for 
values distributed over time. It includes two different projects.

- 1. Plug + Bandit based Elixir API under main directory	
- 2. WebUI composed of Lit + uPlot under  `priv/static/web`

This project aims collecting and displaying information about a system
in terms of time series. For that purpose, we use [white_rabbit](https://github.com/narslan/white_rabbit), a very small time series database implementation over top of ETS and GenServer. 

At the moment, there are a small number of components, which simply collect and display process/memory usage from ErlangVM.

# Usage
Prepare Web-UI
```sh
cd priv/static/web
pnpm i 
pnpm run dev
```
In another console run:
```sh
mix deps.get
iex -S mix
```
Visit in the browser: http://localhost:5173

