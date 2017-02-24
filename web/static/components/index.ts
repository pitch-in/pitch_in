import * as _ from 'lodash';

import HideOn from './HideOn';
import ShortDescription from './ShortDescription';

const components = [
  HideOn,
  ShortDescription
];

export default function ($: JQueryStatic) {
  _.each(components, (Component) => {
    $(`[data-${Component.selector}]`).each(function () {
      new Component($(this));
    });
  });
}
