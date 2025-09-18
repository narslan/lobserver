import { css, html, LitElement } from "lit";
import { customElement, property } from "lit/decorators.js";


import "@spectrum-web-components/theme/sp-theme.js";
import "@spectrum-web-components/theme/spectrum-two/scale-medium.js";
import "@spectrum-web-components/theme/spectrum-two/theme-light.js";

import "@spectrum-web-components/sidenav/sp-sidenav-heading.js";
import "@spectrum-web-components/sidenav/sp-sidenav-item.js";
import "@spectrum-web-components/sidenav/sp-sidenav.js";



@customElement("main-layout")
export class MainLayout extends LitElement {
  @property({ type: String })
  activeTab = "";

  @property({ type: Boolean })
  smallScreen = false;
  @property({ type: Boolean, attribute: true })
  openDrawer = false;

  static styles = css`
    #wrapper {
      display: grid;
      grid-template-columns: minmax(250px, 15%) 1fr;
    }
  `;


  render() {
    return html`
      <header slot="title"></header>
      <div id="wrapper">
        <div id="sidebar">
          <sp-sidenav variant="multilevel" defaultValue="Home">
            <sp-sidenav-item
              value="Home"
              label="Home"
              href="/home"
            ></sp-sidenav-item>           
          </sp-sidenav>
        </div>
        <div id="main-content">
          <slot></slot>
        </div>
      </div>

      <footer></footer>

    `;
  }

  capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
  }
}


declare global {
  interface HTMLElementTagNameMap {
    "main-layout": MainLayout;
  }
}
