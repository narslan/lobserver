import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import './observer';
/**
 * Home element.
 *
 * @slot - This element has a slot
 * @csspart button - The button
 */
@customElement("home-element")
export class HomeElement extends LitElement {
  /**
   * The number of times the button has been clicked.
   */
  @property({ type: Number, attribute: false })
  count = 0;


  render() {
    return html`
     <observer-element></observer-element>
    `;
  }


  static styles = [
    css`
      
        `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    "home-element": HomeElement;
  }
}
