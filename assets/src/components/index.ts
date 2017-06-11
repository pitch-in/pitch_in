import * as _ from "lodash";

import datepicker from "./datepicker";
import HideOn from "./HideOn";
import ShortDescription from "./ShortDescription";
import Tags from "./Tags";

const components = [HideOn, ShortDescription, Tags];

export default function($: JQueryStatic) {
  datepicker();

  _.each(components, Component => {
    $(`[data-${Component.selector}]`).each(function() {
      new Component($(this));
    });
  });
}
