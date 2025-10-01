import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import { map } from "lit/directives/map.js";
import { when } from "lit/directives/when.js";

import "@spectrum-web-components/accordion/sp-accordion-item.js";
import "@spectrum-web-components/table/elements.js";

export interface Process {
	init: string;
	memory: string;
	name: string;
	pid: string;
	reductions: string;
	current: string;
	message_queue_length: string;
}

@customElement("process-element")
export class ProcessElement extends LitElement {
	@property()
	label = "Processes";
	@property({
		converter: (attrValue: string | null) => {
			if (attrValue) return new Date(attrValue);
			else return undefined;
		},
	})
	date?: Date;
	@property()
	process_lines?: Process[];

	// interner Sortierzustand
	@property({ type: String }) sortKey: keyof Process = "memory";
	@property({ type: String }) sortDirection: "asc" | "desc" = "desc";

	private parseMemoryString(mem: string): number {
		if (!mem) return 0;
		const match = mem.match(/^([\d.]+)\s*([KMGTP]?B)$/i);
		if (!match) return 0;

		const value = parseFloat(match[1]);
		const unit = match[2].toUpperCase();

		const multipliers: Record<string, number> = {
			B: 1,
			KB: 1024,
			MB: 1024 ** 2,
			GB: 1024 ** 3,
			TB: 1024 ** 4,
			PB: 1024 ** 5,
		};

		return value * (multipliers[unit] || 1);
	}

	private onSort(e: Event, key: keyof Process) {
		e.preventDefault();
		if (this.sortKey === key) {
			// Richtung toggeln
			this.sortDirection = this.sortDirection === "asc" ? "desc" : "asc";
		} else {
			this.sortKey = key;
			this.sortDirection = "asc";
		}
	}

	private get sortedProcesses(): Process[] {
		if (!this.process_lines) return [];
		return [...this.process_lines].sort((a, b) => {
			const aVal = a[this.sortKey];
			const bVal = b[this.sortKey];
			let cmp: number;

			if (this.sortKey === "memory") {
				cmp =
					this.parseMemoryString(String(aVal)) -
					this.parseMemoryString(String(bVal));
			} else {
				const numA = Number(aVal);
				const numB = Number(bVal);
				cmp =
					isNaN(numA) || isNaN(numB)
						? String(aVal).localeCompare(String(bVal))
						: numA - numB;
			}

			return this.sortDirection === "asc" ? cmp : -cmp; // <= wichtig!
		});
	}

	render() {
		return html`
			<sp-accordion-item label=${this.label}>
				<div id="tree-container">
					<section id="tree-section">
						<sp-table>
							<sp-table-head>
								<sp-table-head-cell align="start"
									>Init</sp-table-head-cell
								>
								<sp-table-head-cell align="start"
									>Current</sp-table-head-cell
								>
								<sp-table-head-cell align="start"
									>Name</sp-table-head-cell
								>
								<sp-table-head-cell
									align="center"
									sortable
									sort-direction=${this.sortKey === "memory"
										? this.sortDirection
										: "none"}
									@click=${(e: Event) =>
										this.onSort(e, "memory")}
									>Memory</sp-table-head-cell
								>

								<sp-table-head-cell align="center"
									>Pid</sp-table-head-cell
								>
								<sp-table-head-cell align="center"

									sortable
									sort-direction=${this.sortKey === "reductions"
										? this.sortDirection
										: "none"}
									@click=${(e: Event) =>
										this.onSort(e, "reductions")}


									>Reductions</sp-table-head-cell
								>
							</sp-table-head>
							<sp-table-body>
								${this.sortedProcesses.map(
									(p) => html`
										<sp-table-row>
											<sp-table-cell
												>${p.init}</sp-table-cell
											>
											<sp-table-cell
												>${p.current}</sp-table-cell
											>
											<sp-table-cell
												>${p.name}</sp-table-cell
											>
											<sp-table-cell
												>${p.memory}</sp-table-cell
											>
											<sp-table-cell
												>${p.pid}</sp-table-cell
											>
											<sp-table-cell
												>${p.reductions}</sp-table-cell
											>
										</sp-table-row>
									`,
								)}
							</sp-table-body>
						</sp-table>
					</section>
				</div>
			</sp-accordion-item>
		`;
	}

	static styles = [
		css`
	sp-table-head-cell:nth-of-type(1),
	sp-table-cell:nth-of-type(1) {
  		width: 80px; /* Init */
	}

	sp-table-head-cell:nth-of-type(2),
	sp-table-cell:nth-of-type(2) {
	  width: 120px; /* Memory */
	  text-align: right;
	}
	
	sp-table-head-cell:nth-of-type(4),
	sp-table-cell:nth-of-type(4) {
	  width: 80px; /* Pid */
	  text-align: right;
	}
	}
		`,
	];
}

declare global {
	interface HTMLElementTagNameMap {
		"process-element": ProcessElement;
	}
}
