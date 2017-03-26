import * as _ from 'lodash'; 
import $ = require('jquery');
import BaseComponent from './BaseComponent';

export default class Tags extends BaseComponent {
  $tags: JQuery;

  constructor(
    public element: JQuery
  ) {
    super(element);

    element.addClass('hide');
    const $tags = $(`<span class="tags" tabindex="0">${element.val()}</span>`).insertAfter(element);

    // new TagPicker($tags, this.element);
  }
  static selector = 'tags';
}

class TagPicker extends BaseComponent {
  $nextInput: JQuery;
  
  constructor(
    public element: JQuery,
    public $input: JQuery
  ) {
    super(element);

    this.element.on('focus', () => console.log('focus'));
    this.element.on('keypress', () => console.log('keypress'));
  }
}
