import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
/**
 * Home element.
 *
 * @slot - This element has a slot
 * @csspart button - The button
 */
@customElement("white-rabbit-element")
export class WhiteRabbitElement extends LitElement {
  private ws: WebSocket | null = null;

  connectedCallback() {
    super.connectedCallback();
    this.ws = new WebSocket("ws://localhost:8000/_pgn");

    this.ws.onopen = () => {
      this.ws!.send(JSON.stringify({ action: "pgn_all", data: [] }));
    };

    this.ws.onmessage = (msg) => {
      const { action, data } = JSON.parse(msg.data);
      if (action === "memory_metric") {
        console.log(data);
      }
    };

    this.ws.onclose = () => {
      console.log("PGN list socket closed");
    };
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    this.ws?.close();
  }

  render() {
    return html`
     <memory-metrics></memory-metrics>
    `;
  }


  static styles = [
    css`
      
        `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    "white-rabbit-element": WhiteRabbitElement;
  }
}
