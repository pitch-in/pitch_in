import * as _ from 'lodash'; 
import $ = require('jquery');

export default class HideOn {
  private controllingElement: JQuery;
  private data: any;

  constructor(
    private element
  ) {
    this.data = element.data();
    this.controllingElement = $(`#${this.data.hideOn}`);

    this.controllingElement.change(this.onHideElementChange);
    this.onHideElementChange();
  }

  private onHideElementChange = () => {
    const value = this.controllingElement.val();

    if (this.isHidden(value)) {
      this.hideElement();
    } else {
      this.showElement();
    }
  };

  private isHidden(value) {
    return !(
      (this.data.showCases &&
       _.includes(this.data.showCases, value)) ||
       this.data.showCase === value
    );
  }

  private hideElement() {
    this.element.hide();
  }

  private showElement() {
    this.element.show();
  }

  static selector = 'hide-on';
}
