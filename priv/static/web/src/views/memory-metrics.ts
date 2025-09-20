import { LitElement, css, html, unsafeCSS } from "lit";
import { customElement, state } from "lit/decorators.js";
import uPlot from "uplot";
import uPlotCss from "uplot/dist/uPlot.min.css?inline";

@customElement("memory-metrics")
export class MemoryMetrics extends LitElement {
	private ws: WebSocket | null = null;

	@state() trendValues: number[] = [];

	private chart: uPlot | null = null;

	render() {
		return html` <h3>Memory</h3>
			<div id="memoryChart"></div>`;
	}

	connectedCallback() {
		super.connectedCallback();
		// Registrierung beim Parent, um die WS zu erhalten
		const parent = this.closest("white-rabbit-element") as any;
		parent?.registerChild(this);
	}

	setWs(ws: WebSocket) {
		this.ws = ws;
	
		this.ws.addEventListener("message", (msg) => {
			const parsed = JSON.parse(msg.data);
			if (parsed.action === "memory_ok") {
				this.handleMessage(parsed);
			}
		});

		setInterval(() => {
			this.sendMetricsRequest();
		}, 1000);
	}

	private sendMetricsRequest() {
		this.ws?.send(JSON.stringify({ action: "memory_metrics" }));
	}

	private handleMessage(parsed) {
		const [xs, ys] = parsed.data;

		if (!this.chart) {
			this.createChart(xs, ys);
		} else {
			this.updateChart(xs, ys);
		}
	}

	private createChart(xs: number[], ys: number[]) {
		const chartDiv = this.renderRoot.querySelector(
			"#memoryChart",
		) as HTMLElement;

		const opts: uPlot.Options = {
			width: 600,
			height: 300,
			title: "Memory Metrics",
			scales: { x: { time: true } }, // Zeitachse aktivieren
			series: [
				{}, // Platzhalter für X-Achse
				{ label: "Processes", stroke: "green", width: 2 },
			],
		};

		this.chart = new uPlot(opts, [xs, ys], chartDiv);
	}

	private updateChart(xs: number[], ys: number[]) {
		if (!this.chart) return;

		// Neue Daten setzen
		this.chart.setData([xs, ys]);
	}

	static styles = [
		css`
			${unsafeCSS(uPlotCss)}
		`,
	];
}
