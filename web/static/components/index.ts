import * as _ from 'lodash';

import datepicker from './datepicker';
import HideOn from './HideOn';
import ShortDescription from './ShortDescription';

const components = [
  HideOn,
  ShortDescription
];

export default function ($: JQueryStatic) {
  datepicker();

  _.each(components, (Component) => {
    $(`[data-${Component.selector}]`).each(function () {
      new Component($(this));
    });
  });
}
