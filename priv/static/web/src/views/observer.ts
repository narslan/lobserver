import "@spectrum-web-components/accordion/sp-accordion.js";
import { LitElement, css, html } from "lit";
import { customElement, state } from "lit/decorators.js";
import "./memory";
import { Memory } from "./memory";
import "./process";
import { Process } from "./process";
@customElement("observer-element")
export class ObserverElement extends LitElement {
  @state()
  ws = new WebSocket(`ws://localhost:8000/_memory`);
  @state()
  memory_lines?: Memory[] = [];
  @state()
  process_lines?: Process[] = [];
  render() {
    return html`
      <sp-accordion>
        <memory-element .memory_lines=${this.memory_lines}> </memory-element>
      </sp-accordion>
      <sp-accordion>
        <process-element .process_lines=${this.process_lines}>
        </process-element>
      </sp-accordion>
    `;
  }

  async connectedCallback() {
    super.connectedCallback();
    await this.updateComplete;
    const that = this;
    this.ws.onmessage = function (msg: MessageEvent) {
      const { action, data } = msg.data.startsWith("{")
        ? (JSON.parse(msg.data) as {
            action: string;
            data: [];
          })
        : { action: "", data: [] };

      if (action === "result_memory") {
        console.log(data)
        console.log(that.memory_lines)
        that.memory_lines! = [...that.memory_lines, ...data];
      } else if (action === "result_process") {
        that.process_lines = [...that.process_lines, ...data];
        console.log(that.process_lines);
      }
    };

    this.ws.onopen = () => {
      const mem_request = { action: "onMemory" };
      this.ws.send(JSON.stringify(mem_request));
      const process_request = { action: "onProcess" };
      this.ws.send(JSON.stringify(process_request));
    };
    this.ws.onclose = () => {
      const expression = { action: "onMemoryClose" };
      this.ws.send(JSON.stringify(expression));
    };
  }

  async firstUpdated() {
    // Give the browser a chance to paint
    await new Promise((r) => setTimeout(r, 0));
    setInterval(() => {
      this.ws.send("pong");
    }, 1000);
  }

  async disconnectedCallback() {
    super.disconnectedCallback();
    this.ws.close();
  }

  static styles = [css``];
}

declare global {
  interface HTMLElementTagNameMap {
    "observer-element": ObserverElement;
  }
}
