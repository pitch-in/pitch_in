// Any jquery
const $ = require('jquery');

// Datepicker
import '@fengyuanchen/datepicker';

export default function setUpDatepickers() {
  $('[data-toggle="datepicker"]').datepicker({
    format: 'm/d/yyyy'
  });
}
