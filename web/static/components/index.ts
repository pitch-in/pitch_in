import * as _ from 'lodash';

import HideOn from './HideOn';

const components = [
  HideOn
];

export default function ($: JQueryStatic) {
  _.each(components, (Component) => {
    $(`[data-${Component.selector}]`).each(function () {
      new Component($(this));
    });
  });
}
