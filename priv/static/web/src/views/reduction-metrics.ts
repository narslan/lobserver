import { LitElement, css, html, unsafeCSS } from "lit";
import { customElement, state } from "lit/decorators.js";
import uPlot from "uplot";
import uPlotCss from "uplot/dist/uPlot.min.css?inline";

@customElement("reduction-metrics")
export class ReductionMetrics extends LitElement {
	private ws: WebSocket | null = null;

	@state() trendValues: number[] = [];

	private chart: uPlot | null = null;

	render() {
		return html` <h3>Change of Reductions over Time</h3>
			<div id="reductionChart"></div>`;
	}

	connectedCallback() {
		super.connectedCallback();
		// Registrierung beim Parent, um die WS zu erhalten
		const parent = this.closest("metrics-element") as any;
		parent?.registerChild(this);
	}

	setWs(ws: WebSocket) {
		this.ws = ws;
		//		this.sendMetricsRequest();
		console.log("send metrics");
		this.ws.addEventListener("message", (msg) => {
			const parsed = JSON.parse(msg.data);
			if (parsed.action === "reductions_ok") {
				this.handleMessage(parsed);
			}
		});
		setInterval(() => {
			this.sendMetricsRequest();
		}, 1000);
	}

	private sendMetricsRequest() {
		this.ws?.send(JSON.stringify({ action: "reductions_metrics" }));
	}

	private handleMessage(parsed) {
		const [xs, ys1, ys2] = parsed.data;

		if (!this.chart) {
			this.createChart(xs, ys1, ys2);
		} else {
			this.updateChart(xs, ys1, ys2);
		}
	}

	private createChart(xs: number[], ys1: number[], ys2: number[]) {
		const chartDiv = this.renderRoot.querySelector(
			"#reductionChart",
		) as HTMLElement;

		const opts: uPlot.Options = {
			width: 600,
			height: 300,
			title: "Reduction Metrics",
			scales: {
				x: { time: true },
				y: { auto: true }, // für Reductions
				y2: { auto: true }, // für GC-Reductions
			},
			axes: [
				{ scale: "x" },
				{
					scale: "y",
					side: 3,
					size: 60,
				}, // rechte Y-Achse
				{ scale: "y2", side: 1, size: 60 }, // linke Y-Achse
			],
			series: [
				{}, // X-Achse
				{ label: "Reductions", stroke: "green", width: 2, scale: "y" },
				{
					label: "GC Reductions",
					stroke: "red",
					width: 2,
					scale: "y2",
				},
			],
		};

		this.chart = new uPlot(opts, [xs, ys1, ys2], chartDiv);
	}

	private updateChart(xs: number[], ys1: number[], ys2: number[]) {
		if (!this.chart) return;
		this.chart.setData([xs, ys1, ys2]);
	}
	static styles = [
		css`
			${unsafeCSS(uPlotCss)}
		`,
	];
}
