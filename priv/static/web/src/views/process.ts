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

	render() {
		return html`
			<sp-accordion-item label=${this.label}>
				<div id="tree-container">
					<section id="tree-section">
						<sp-table >
							<sp-table-head>
								<sp-table-head-cell>Init</sp-table-head-cell>
								<sp-table-head-cell
									>Memory</sp-table-head-cell
								>
								<sp-table-head-cell>Name</sp-table-head-cell>
								<sp-table-head-cell>Pid</sp-table-head-cell>
								<sp-table-head-cell>Reductions</sp-table-head-cell>
								<sp-table-head-cell>Current</sp-table-head-cell>
								<sp-table-head-cell>Message Queue</sp-table-head-cell>
							</sp-table-head>
							<sp-table-body>
								${when(
									this.process_lines,
									() =>
										map(
											this.process_lines!,
											(key) =>
												html` <sp-table-row>
													<sp-table-cell
														>${key.init}
													</sp-table-cell>
													<sp-table-cell
														>${key.memory}
													</sp-table-cell>
													<sp-table-cell
														>${key.name}
													</sp-table-cell>
													<sp-table-cell
														>${key.pid}
													</sp-table-cell>
													<sp-table-cell
														>${key.reductions}
													</sp-table-cell>
													<sp-table-cell
														>${key.current}
													</sp-table-cell>
																										<sp-table-cell
														>${key.message_queue_length}
													</sp-table-cell>
												</sp-table-row>`,
										),
									() => html`Loading processes...`,
								)}
							</sp-table-body>
						</sp-table>
					</section>
				</div>
			</sp-accordion-item>
		`;
	}

	static styles = [css``];
}

declare global {
	interface HTMLElementTagNameMap {
		"process-element": ProcessElement;
	}
}
