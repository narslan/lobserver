import { LitElement, css, html } from "lit";
import { customElement } from "lit/decorators.js";
import "./process-metrics";

/**
 * Home element.
 *
 * @slot - This element has a slot
 * @csspart button - The button
 */
@customElement("white-rabbit-element")
export class WhiteRabbitElement extends LitElement {
  private ws: WebSocket | null = null;
  // Hier speichern wir die Liste der Kinder-Komponenten, die ws nutzen
  private childrenWaiting: any[] = [];

  connectedCallback() {
    super.connectedCallback();
    this.ws = new WebSocket("ws://localhost:8000/_metrics");

    // Nur wenn die WS offen ist, die Kinder informieren
    this.ws.addEventListener("open", () => {
      console.log("WebSocket connected");
      this.childrenWaiting.forEach((child) => {
        child.setWs(this.ws!);
      });
      this.childrenWaiting = [];
    });

    this.ws.onclose = () => console.log("Metrics socket closed");
  }

  /** Methode für Kinder, um die WS zu erhalten */
  registerChild(child: any) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      child.setWs(this.ws);
    } else {
      this.childrenWaiting.push(child);
    }
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    this.ws?.close();
  }

  render() {
    const child = html`<process-metrics></process-metrics>`;
    setTimeout(() => {
      const el = this.renderRoot.querySelector("process-metrics");
      if (el) this.registerChild(el);
    });
    return child;
  }

  static styles = [css``];
}

declare global {
  interface HTMLElementTagNameMap {
    "white-rabbit-element": WhiteRabbitElement;
  }
}
