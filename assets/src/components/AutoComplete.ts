import { bindAll } from 'lodash';
import AutoCompleteItem from './AutoCompleteItem';

export interface IAutoCompleteProps {
  values: string[];
  onClick: (value: string) => void;
  onFocus: (value: string) => void;
  onBlur: (value: string) => void;
}

export default class AutoComplete {
  public $element: JQuery;
  constructor(public props: IAutoCompleteProps) {
    bindAll(this, ['renderItem']);
  }

  render() {
    const { values } = this.props;

    const list = values.map(this.renderItem);
    this.$element = $(`<div class="auto-complete"></div>`);
    this.$element.append(list);

    return this.$element;
  }

  renderItem(value) {
    const { onClick, onFocus, onBlur } = this.props;

    const item = new AutoCompleteItem({
      value,
      onClick,
      onFocus,
      onBlur
    });
    return item.render();
  }
}
