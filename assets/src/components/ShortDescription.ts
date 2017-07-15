import $ = require("jquery");
import BaseComponent from "./BaseComponent";

const starterText = {
  candidate: "I want to...",
  measure: "We want...",
  issue: "We believe..."
};

export default class ShortDescription extends BaseComponent {
  private $campaignType: JQuery;
  private currentStarter: string;

  constructor(public element) {
    super(element);

    this.$campaignType = element
      .parents("form")
      .find(`#${this.data.shortDescription}`);

    this.updateStarter();
    this.$campaignType.change(() => this.updateStarter());
    this.element.focus(() => this.insertStarter());
    this.element.blur(() => this.clearStarter());
  }

  private updateStarter() {
    const type: string = this.$campaignType.val();
    this.currentStarter = starterText[type] || "";

    this.element.attr("placeholder", this.currentStarter);
  }

  private insertStarter() {
    if (this.element.val().length) {
      return;
    }

    this.element.val(this.currentStarterForInput);
  }

  private clearStarter() {
    if (this.element.val() !== this.currentStarterForInput) {
      return;
    }

    this.element.val("");
  }

  private get currentStarterForInput() {
    return this.currentStarter.replace("...", " ");
  }

  static selector = "short-description";
}
