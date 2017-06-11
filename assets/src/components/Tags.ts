import * as _ from "lodash";
import $ = require("jquery");
import BaseComponent from "./BaseComponent";

const defaultValues = {
  "Web Development": ["html", "css", "application development"],
  Data: ["data analysis", "data science"],
  Design: ["digital design", "print design"]
};

export default class Tags extends BaseComponent {
  $tags: JQuery;

  constructor(public element) {
    super(element);

    element.addClass("hide");
    const $tags = $(`<div class="tags"></div>`).insertAfter(element);
    const watchId: string = element.data("tagsWatch");
    const $watched = watchId ? $(`#${watchId}`) : undefined;

    new TagPicker($tags, this.element, $watched);
  }

  static selector = "tags";
}

const confirmKeys = [9, 13];

class TagPicker extends BaseComponent {
  tags: string[];
  $nextInput: JQuery;
  $tagsContainer: JQuery;

  constructor(
    public element: JQuery,
    public $input: JQuery,
    public $watched: JQuery
  ) {
    super(element);

    const placeholder = $input.attr("placeholder");
    this.$nextInput = $(
      `<input class="tags__next-input" type="text" placeholder="${placeholder ||
        "enter tags..."}"/>`
    );
    this.$tagsContainer = $('<div class="tags__container"></div>');

    this.element.append(this.$nextInput);
    this.element.append(this.$tagsContainer);

    this.initializeTags();

    this.render();

    this.onKeyPress = this.onKeyPress.bind(this);
    this.onInput = this.onInput.bind(this);
    this.onTagClick = this.onTagClick.bind(this);
    this.finishTag = this.finishTag.bind(this);
    this.element.on("keydown", this.$nextInput, this.onKeyPress);
    this.element.on("input", this.$nextInput, this.onInput);
    this.element.on("click", ".tags__tag", this.onTagClick);
    this.element.on("blur", ".tags__next-input", this.finishTag);

    if (this.$watched) {
      this.onWatchChange = this.onWatchChange.bind(this);
      this.$watched.on("change", this.onWatchChange);
    }
  }

  onKeyPress(event) {
    const key = event.which;

    if (_.includes(confirmKeys, key)) {
      this.finishTag();
      event.preventDefault();
    } else if (key === 8 && this.$nextInput.val() === "") {
      this.removeLastTag();
    }
  }

  onInput() {
    const value: string = this.$nextInput.val();

    if (value.slice(-1) === ",") {
      const newValue: string = value.slice(0, -1);
      this.$nextInput.val(newValue);

      this.finishTag();
    }
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
    if (_.trim(nextTag) === "") {
      return;
    }

    this.tags.push(nextTag);
    this.tags = _.uniq(this.tags);

    this.render();
  }

  initializeTags() {
    const inputVal = this.$input.val().trim();
    this.tags = inputVal === "" ? [] : inputVal.split(",");
  }

  clearInput() {
    this.$nextInput.val("");
  }

  tagsToString(): string {
    return this.tags.join(",");
  }

  tagHtml(value: string | number): string {
    return `<span class="tags__tag">${value}<span class="tags__tag-closer"></span></span>`;
  }

  writeTags() {
    this.$input.val(this.tagsToString());

    const tagsHtml = _.map(this.tags, this.tagHtml).join("");
    this.$tagsContainer.html(tagsHtml);
  }
}
