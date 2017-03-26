import * as _ from 'lodash'; 
import $ = require('jquery');
import BaseComponent from './BaseComponent';

export default class Tags extends BaseComponent {
  $tags: JQuery;

  constructor(
    public element
  ) {
    super(element);

    element.addClass('hide');
    const $tags = $(`<label class="tags"></label>`).insertAfter(element);

    new TagPicker($tags, this.element);
  }

  static selector = 'tags';
}

const confirmKeys = [9, 13, 188];

class TagPicker extends BaseComponent {
  tags: string[];
  $nextInput: JQuery;

  constructor(
    public element: JQuery,
    public $input: JQuery
  ) {
    super(element);

    const placeholder = $input.attr('placeholder');
    this.$nextInput = $(`<input class="tags__next-input" type="text" placeholder="${placeholder || 'enter tags...'}"/>`);

    this.initializeTags();

    this.render();

    this.onKeyPress = this.onKeyPress.bind(this);
    this.onTagClick = this.onTagClick.bind(this);
    this.element.on('keydown', this.$nextInput, this.onKeyPress);
    this.element.on('click', '.tags__tag', this.onTagClick);
  }

  onKeyPress(event) {
    const key = event.which;

    if (_.includes(confirmKeys, key)) {
      this.finishTag();
      event.preventDefault();
    } else if (key === 8 && this.$nextInput.val() === '') {
      this.removeLastTag();
    }
  }

  onTagClick(event) {
    const tag = $(event.currentTarget);
    console.log(event.currentTarget);
    console.log(tag.val());
    this.removeTag(tag.text());
  }

  render() {
    this.writeTags();
    this.startNextTag();
  }

  renderAndFocus() {
    this.render();
    this.$nextInput.focus();
  }

  removeLastTag() {
    this.tags.pop();
    this.render();
  }

  removeTag(value: string) {
    this.tags = _.reject(this.tags, tag => tag === value);
    this.renderAndFocus();
  }

  finishTag() {
    const nextTag = this.$nextInput.val();
    if (_.trim(nextTag) === '') {
      return;
    }

    this.tags.push(nextTag);
    this.tags = _.uniq(this.tags);

    this.render();
  }

  initializeTags() {
    const inputVal = this.$input.val().trim();
    this.tags = inputVal === '' ? [] : inputVal.split(',');
  }

  startNextTag() {
    this.$nextInput.val('');
    this.element.append(this.$nextInput);
  }

  tagsToString(): string {
    return this.tags.join(',');
  }

  tagHtml(value: string | number): string {
    return `<span class="tags__tag">${value}<span class="tags__tag-closer"></span></span>`;
  }

  writeTags() {
    this.$input.val(this.tagsToString());

    const tagsHtml = _.map(this.tags, this.tagHtml).join('');
    this.element.html(tagsHtml);
  }
}
