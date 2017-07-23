import { forEach } from 'ramda';

import datepicker from './datepicker';
import HideOn from './HideOn';
import ShortDescription from './ShortDescription';
import Tags from './Tags';

const topComponents = [HideOn, ShortDescription, Tags];

export default function($: JQueryStatic) {
  datepicker();

  forEach(Component => {
    $(`[data-${Component.selector}]`).each(function() {
      new Component($(this));
    });
  }, topComponents);
}
