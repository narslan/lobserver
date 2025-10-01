import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";

@customElement("process-info-modal")
export class ProcessInfoModal extends LitElement {
  @property({ type: Object }) processData: any = null;

  render() {
    if (!this.processData) {
      return html`<div class="empty">Keine Prozessdetails ausgewählt.</div>`;
    }

    return html`
      <h3>Prozess-Details</h3>
      <table>
        <tbody>
          ${Object.entries(this.processData).map(
            ([key, value]) => html`
              <tr>
                <td class="key">${key}</td>
                <td class="value">
                  ${typeof value === "object"
                    ? html`<pre>${JSON.stringify(value, null, 2)}</pre>`
                    : String(value)}
                </td>
              </tr>
            `
          )}
        </tbody>
      </table>
    `;
  }

  static styles = css`
    :host {
      display: block;
      font-family: var(--spectrum-global-font-family-base, Arial, sans-serif);
      color: var(--spectrum-global-color-gray-800, #333);
    }

    h3 {
      margin: 0 0 0.5rem 0;
      font-size: 1.1rem;
      font-weight: bold;
    }

    table {
      width: 100%;
      border-collapse: collapse;
    }

    td {
      padding: 0.4rem 0.6rem;
      vertical-align: top;
      border-bottom: 1px solid var(--spectrum-global-color-gray-300, #ddd);
    }

    .key {
      font-weight: bold;
      width: 180px;
      background: var(--spectrum-global-color-gray-75, #f9f9f9);
    }

    .value pre {
      margin: 0;
      font-family: monospace;
      white-space: pre-wrap;
      word-wrap: break-word;
    }

    .empty {
      font-style: italic;
      color: var(--spectrum-global-color-gray-500, #888);
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    "process-info-modal": ProcessInfoModal;
  }
}
