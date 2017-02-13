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
    if (this.isShown()) {
      this.showElement();
    } else {
      this.hideElement();
    }
  };

  private isShown() {
    const value = this.controllingElement.val();
    const checked: boolean = this.controllingElement.is(':checked');

    return (
      this.data.showCase === value ||
      (this.data.showCases &&
        _.includes(this.data.showCases, value)) ||
      (this.data.showChecked && checked) ||
      (this.data.showChecked === false && !checked)
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
