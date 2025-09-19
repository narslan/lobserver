import { LitElement, css, html, unsafeCSS } from "lit";
import { customElement, state } from "lit/decorators.js";
import uPlot from "uplot";
import uPlotCss from "uplot/dist/uPlot.min.css?inline";

@customElement("process-metrics")
export class ProcessMetrics extends LitElement {
	private ws: WebSocket | null = null;

	@state() trendValues: number[] = [];

	private chart: uPlot | null = null;

	render() {
		return html` <h3>Process</h3>
			<div id="trendChart"></div>`;
	}

	connectedCallback() {
		super.connectedCallback();
		// Registrierung beim Parent, um die WS zu erhalten
		const parent = this.closest("white-rabbit-element") as any;
		parent?.registerChild(this);
	}

	setWs(ws: WebSocket) {
		this.ws = ws;
		//		this.sendMetricsRequest();
		console.log("send metrics");
		this.ws.onmessage = this.handleMessage.bind(this);
		setInterval(() => {
			this.sendMetricsRequest();
		}, 1000);
	}

	private sendMetricsRequest() {
		this.ws?.send(JSON.stringify({ action: "process_metrics" }));
	}

	private handleMessage(msg: MessageEvent) {
		const parsed = JSON.parse(msg.data);

		if (parsed.action === "process_metrics_ok") {
			console.log("Received metrics", parsed.data);
			const [xs, ys] = parsed.data;

			if (!this.chart) {
				this.createChart(xs, ys);
			} else {
				this.updateChart(xs, ys);
			}
		}
	}

	private createChart(xs: number[], ys: number[]) {
		const chartDiv = this.renderRoot.querySelector(
			"#trendChart",
		) as HTMLElement;

		const opts: uPlot.Options = {
			width: 600,
			height: 300,
			title: "Process Metrics",
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
