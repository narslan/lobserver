import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import { map } from "lit/directives/map.js";
import { when } from "lit/directives/when.js";

import "@spectrum-web-components/accordion/sp-accordion-item.js";
import "@spectrum-web-components/table/elements.js";

export interface Memory{
  key: string;
  value: string;
}
@customElement("memory-element")
export class MemoryElement extends LitElement {
  @property()
  label = "Memory";
  @property({
    converter: (attrValue: string | null) => {
      if (attrValue) return new Date(attrValue);
      else return undefined;
    },
  })
  date?: Date;
  @property()
  memory_lines?: Memory[];

  render() {
    return html`
      <sp-accordion-item label=${this.label}>
        <div id="tree-container">
          <section id="tree-section">
            <sp-table density="spacious" size="l">
              <sp-table-head>
                <sp-table-head-cell>ID</sp-table-head-cell>
                <sp-table-head-cell>Property</sp-table-head-cell>
              </sp-table-head>
              <sp-table-body>
                ${when(this.memory_lines,
                () => map(
                  this.memory_lines,
                  (key) =>
                    html` <sp-table-row>
                      <sp-table-cell>${key.key} </sp-table-cell>
                      <sp-table-cell>${key.value} </sp-table-cell>
                    </sp-table-row>`,
                )
                , 
                () => html`Loading memory...`)
              }
              </sp-table-body>
            </sp-table>
          </section>
        </div>
      </sp-accordion-item>
    `;
  }

  static styles = [css`
  `];
}

declare global {
  interface HTMLElementTagNameMap {
    "memory-element": MemoryElement;
  }
}
