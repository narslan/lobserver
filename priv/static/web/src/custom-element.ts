import { LitElement, css, html } from "lit";
import { customElement, state, query} from "lit/decorators.js";

/**
 * Shell-element element.
 *
 * @slot - This element has a slot
 * @csspart button - The button
 */
@customElement("shell-element-element")
export class Shell-elementElement extends LitElement {
  
  @query("#result")
  _result: any;
    @state()
  ws = new WebSocket(`ws://localhost:8000/_shell-element`);

  render() {
    return html`
     <h1>shell </h1>  
     <p>hello home </p>
    `;
  }


 async connectedCallback() {
    super.connectedCallback();
    await this.updateComplete;
    const that = this;
    this.ws.onmessage = function (msg: MessageEvent) {
      console.log(msg)

      const { action, data } = msg.data.startsWith("{")
        ? (JSON.parse(msg.data) as {
          action: string;
          data: string;
        })
        : { action: "", data: "" };

      if (action === "result") {
        console.log(data);
        that._result.innerHTML = JSON.stringify(data, null, "\t");
      }
      console.log(action, data);
    };

    this.ws.onopen = () => {
      const expression = { action: "onOpen" };
      this.ws.send(JSON.stringify(expression));
    };
    this.ws.onclose = () => {
      const expression = { action: "onClose" };
      this.ws.send(JSON.stringify(expression));
    };

    
  }

  async firstUpdated() {
    // Give the browser a chance to paint
    await new Promise((r) => setTimeout(r, 0));
    setInterval(() => {
      this.ws.send(JSON.stringify("pong"));
    }, 1000);
    
  }

  async disconnectedCallback() {
    super.disconnectedCallback();
    this.ws.close();
  }

  static styles = [
    css`
      
        `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    "shell-element-element": Shell-elementElement;
  }
}
