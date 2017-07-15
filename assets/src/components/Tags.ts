import { bindAll, reject, includes, trim, uniq, map } from 'lodash';
import $ = require('jquery');
import BaseComponent from './BaseComponent';
import AutoComplete from './AutoComplete';

const defaultValues = {
  'Web Development': ['html', 'css', 'application development'],
  Data: ['data analysis', 'data science'],
  Design: ['digital design', 'print design']
};

export default class Tags extends BaseComponent {
  $tags: JQuery;

  constructor(public element) {
    super(element);

    element.addClass('hide');
    const $tags = $(`<div class="tags"></div>`).insertAfter(element);
    const watchId: string = element.data('tagsWatch');
    const tagType = element.data('tags');
    const $watched = watchId ? $(`#${watchId}`) : undefined;

    new TagPicker($tags, this.element, $watched, tagType);
  }

  static selector = 'tags';
}

enum Keys {
  Backspace = 8,
  Enter = 13,
  Escape = 27
}

const confirmKeys = [Keys.Enter];

class TagPicker extends BaseComponent {
  tags: string[];
  $nextInput: JQuery;
  $tagsContainer: JQuery;
  $autoComplete: JQuery;
  autoCompleteValues: string[];
  autoCompleteFocused: boolean;

  constructor(
    public element: JQuery,
    public $input: JQuery,
    public $watched: JQuery,
    public tagType: string
  ) {
    super(element);

    this.autoCompleteValues = [];
    this.autoCompleteFocused = false;

    const placeholder = $input.attr('placeholder');
    this.$nextInput = $(
      `<input class="tags__next-input" type="text" placeholder="${placeholder ||
        'enter tags...'}"/>`
    );
    this.$tagsContainer = $(`<div class="tags__container"></div>`);
    this.$autoComplete = $(`<div class="tags__auto-complete"></div>`);

    this.element.append(this.$nextInput);
    this.element.append(this.$tagsContainer);
    this.element.append(this.$autoComplete);

    this.initializeTags();

    this.render();

    bindAll(this, [
      'onKeyPress',
      'onInput',
      'onInputBlur',
      'onTagClick',
      'finishTag',
      'showAutoCompleteIfEmpty',
      'onAutoCompleteClick',
      'onAutoCompleteFocus',
      'closeAutoCompleteOnBlur',
      'saveTagIfAutoCompleteEmpty'
    ]);

    this.element.on('keydown', this.$nextInput, this.onKeyPress);
    this.element.on('input', this.$nextInput, this.onInput);
    this.$nextInput.focus(this.showAutoCompleteIfEmpty);
    this.$nextInput.blur(this.onInputBlur);
    this.element.on('click', '.tags__tag', this.onTagClick);

    if (this.$watched) {
      this.onWatchChange = this.onWatchChange.bind(this);
      this.$watched.on('change', this.onWatchChange);
    }
  }

  onKeyPress(event) {
    const key = event.which;

    if (includes(confirmKeys, key)) {
      this.finishTag();
      event.preventDefault();
    } else if (key === Keys.Backspace && this.$nextInput.val() === '') {
      this.removeLastTag();
    } else if (key === Keys.Escape) {
      this.clearAutoComplete();
    }
  }

  onInput() {
    const value: string = this.$nextInput.val();

    if (this.endsWithComma(value)) {
      const newValue: string = this.removeComma(value);
      this.$nextInput.val(newValue);

      this.finishTag();
    } else {
      this.fetchAutoCompleteValues(value);
    }
  }

  fetchAutoCompleteValues(value) {
    if (this.tagType !== 'issues') {
      return;
    }

    $.ajax({
      dataType: 'json',
      method: 'GET',
      url: `/api/${this.tagType}?filter=${value}`
    }).done(response => {
      this.setAutoCompleteValues(response.data);
      this.renderAutocomplete();
    });
  }

  onWatchChange() {
    const value: string = this.$watched.val();

    this.tags = defaultValues[value] || [];

    this.render();
  }

  onTagClick(event) {
    const tag = $(event.currentTarget);
    this.removeTag(tag.text());
  }

  render() {
    this.writeTags();
    this.clearInput();
    this.$autoComplete.empty();
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
    this.tags = reject(this.tags, tag => tag === value);
    this.renderAndFocus();
  }

  finishTag() {
    const nextTag = this.$nextInput.val();
    if (trim(nextTag) === '') {
      return;
    }

    this.tags.push(nextTag);
    this.tags = uniq(this.tags);

    this.render();
  }

  initializeTags() {
    const inputVal = this.$input.val().trim();
    this.tags = inputVal === '' ? [] : inputVal.split(',');
  }

  clearInput() {
    this.$nextInput.val('');
  }

  tagsToString(): string {
    return this.tags.join(',');
  }

  tagHtml(value: string | number): string {
    return `<span class="tags__tag">${value}<span class="tags__tag-closer"></span></span>`;
  }

  writeTags() {
    this.$input.val(this.tagsToString());

    const tagsHtml = map(this.tags, this.tagHtml).join('');
    this.$tagsContainer.html(tagsHtml);
  }

  renderAutocomplete() {
    this.clearAutoComplete();
    const autoComplete = new AutoComplete({
      values: this.autoCompleteValues,
      onClick: this.onAutoCompleteClick,
      onFocus: this.onAutoCompleteFocus,
      onBlur: this.closeAutoCompleteOnBlur
    });
    this.$autoComplete.append(autoComplete.render());
  }

  setAutoCompleteValues(tags: string) {
    const inputValue = this.$nextInput.val();
    const filteredValues = reject(tags, tag => tag === inputValue);
    console.log(filteredValues);
    this.autoCompleteValues = filteredValues;
  }

  clearAutoComplete() {
    this.$autoComplete.empty();
  }

  onAutoCompleteClick(value) {
    this.autoCompleteValues = [];
    this.$nextInput.val(value);
    this.finishTag();
    this.renderAndFocus();
  }

  onAutoCompleteFocus(value) {
    this.$nextInput.val(value);
  }

  showAutoCompleteIfEmpty() {
    if (!(this.$nextInput.val() || this.autoCompleteValues.length)) {
      this.fetchAutoCompleteValues('');
    }
  }

  onInputBlur() {
    this.saveTagIfAutoCompleteEmpty();
    this.closeAutoCompleteOnBlur();
  }

  closeAutoCompleteOnBlur() {
    setTimeout(() => {
      if (!this.isFocused()) {
        this.autoCompleteValues = [];
        this.clearAutoComplete();
      }
    }, 100);
  }

  isFocused() {
    return (
      this.$input.is(':focus') ||
      this.$autoComplete.find('.auto-complete__item').is(':focus')
    );
  }

  saveTagIfAutoCompleteEmpty() {
    console.log(this.$nextInput.val(), this.autoCompleteValues.length);
    if (this.$nextInput.val() && !this.autoCompleteValues.length) {
      this.finishTag();
    }
  }

  endsWithComma(value): boolean {
    return value.slice(-1) === ',';
  }

  removeComma(value): string {
    return value.slice(0, -1);
  }
}
