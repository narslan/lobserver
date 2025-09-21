# lobserver

`lobserver` is an Elixir layout to create web dashboards for 
values distributed over time (telemetry events, resources usage etc.). It includes two different projects.

- 1. Plug + Bandit based Elixir API under main directory	
- 2. WebUI composed of Lit + uPlot under  `priv/static/web`

This project aims collecting and displaying information about a system
in terms of time series. For that purpose, we use [white_rabbit](https://github.com/narslan/white_rabbit), a very small time series database implementation over top of ETS and GenServer. 

At the moment, there are a small number of components, which simply collect and display process/memory usage from ErlangVM.

# Usage
```elixir
 defp deps do
    [
      {:lobserver, ">= 0.1.0", github: "narslan/lobserver"}
    ]
  end
```
Run mix deps.get to fetch the dependency.

Add the `:lobserver` to extra_applications:
```elixir
 def application do
    [
      extra_applications: [:logger, :lobserver]
    ]
  end
```
Prepare Web-UI

```sh

cd _build/dev/lib/lobserver/priv/static/web
pnpm i 
pnpm run dev

```
In another console run:
```sh
mix deps.get
iex -S mix
```
Visit in the browser: http://localhost:8000

