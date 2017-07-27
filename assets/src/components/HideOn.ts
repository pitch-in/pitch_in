import $ = require('jquery');
import { contains } from 'ramda';

import BaseComponent from './BaseComponent';

export default class HideOn extends BaseComponent {
  private controllingElement: JQuery;

  constructor(public element) {
    super(element);

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
      (this.data.showCases && contains(value, this.data.showCases)) ||
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
