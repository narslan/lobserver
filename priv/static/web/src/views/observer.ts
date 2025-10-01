import "@spectrum-web-components/accordion/sp-accordion.js";
import { LitElement, css, html } from "lit";
import { customElement, state } from "lit/decorators.js";
import "./memory";
import { Memory } from "./memory";
import "./process";
import { Process } from "./process";
import "./process-info-modal";

@customElement("observer-element")
export class ObserverElement extends LitElement {
  @state() ws = new WebSocket(`ws://localhost:8000/_memory`);
  @state() memory_lines?: Memory[] = [];
  @state() process_lines?: Process[] = [];
  @state() selectedProcess: any = null;
  private handleRowClick(e: CustomEvent<{ pid: string }>) {
    const pid = e.detail.pid;
    this.ws.send(JSON.stringify({ action: "get_process_info", pid }));
  }

  render() {
    return html`
      <sp-accordion>
        <memory-element .memory_lines=${this.memory_lines}></memory-element>
      </sp-accordion>

      <sp-accordion>
        ${this.selectedProcess
          ? html`
              <div class="detail-panel">
                <process-info-modal
                  .processData=${this.selectedProcess}
                ></process-info-modal>
              </div>
            `
          : ""}
        <process-element
          .process_lines=${this.process_lines}
          @row-click=${this.handleRowClick}
        ></process-element>
      </sp-accordion>
    `;
  }

  async connectedCallback() {
    super.connectedCallback();
    await this.updateComplete;

    this.ws.onmessage = (msg: MessageEvent) => {
      const { action, data } = msg.data.startsWith("{")
        ? (JSON.parse(msg.data) as { action: string; data: any })
        : { action: "", data: [] };

      if (action === "result_memory") {
        this.memory_lines = data;
      } else if (action === "result_process") {
        this.process_lines = data;
      } else if (action === "result_process_info") {
        this.selectedProcess = data;
      }
    };

    this.ws.onopen = () => {
      this.ws.send(JSON.stringify({ action: "get_memory" }));
      this.ws.send(JSON.stringify({ action: "get_processes" }));
    };

    this.ws.onclose = () => {
      this.ws.send(JSON.stringify({ action: "onMemoryClose" }));
    };
  }

  async firstUpdated() {
    await new Promise((r) => setTimeout(r, 0));

    // Alle 10 Sekunden "ping" senden
    setInterval(() => {
      if (this.ws.readyState === WebSocket.OPEN) {
        this.ws.send("ping");
      }
    }, 10_000);
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    this.ws.close();
  }

  static styles = css`
    .detail-panel {
      margin-top: 1rem;
      border: 1px solid var(--spectrum-global-color-gray-300);
      border-radius: 6px;
      background: var(--spectrum-global-color-gray-50);
      padding: 1rem;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    "observer-element": ObserverElement;
  }
}
