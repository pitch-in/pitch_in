import { bindAll } from "lodash";

export interface IAutoCompleteItemProps {
  value: string;
  onClick: (value: string) => void;
  onFocus: (value: string) => void;
}

export default class AutoCompleteItem {
  public $element: JQuery;
  constructor(public props: IAutoCompleteItemProps) {}

  render() {
    const { value, onClick, onFocus } = this.props;

    this.$element = $(`<button type="button" class="auto-complete__item">${value}</button>`);
    this.$element.click(() => onClick(value));
    this.$element.keydown((event) => {
      if (event.which === 13) {
        event.preventDefault();
        onClick(value);
      }
    });

    this.$element.focus(() => onFocus(value));

    return this.$element;
  }
}
