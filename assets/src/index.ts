import "babel-polyfill";
import "phoenix";
import "phoenix_html";
// Expose jquery, for Foundation.
const $ = require("expose?$!expose?jQuery!jquery");

import "./styles/main.scss";
import "./fonts/Phosphate-Inline.ttf";
import "./fonts/Phosphate-Solid.ttf";

const hero_path: string = require("./img/homepage/hero.jpg");
import "./img/homepage/the-organizers.jpg";

import "./favicon.ico";
import "./apple-touch-icon.png";
import "./loaderio-5c03e76471bc81be95a31e8c9013e53c.txt";

import "./img/logo.svg";
import "./img/shovels.svg";
import "./img/logo_blue.png";

import "./img/verified.png";
import "./img/expand-icon.svg";
import "./img/minimize-icon.svg";
import "./img/report-problem-icon.svg";

import "./img/about/chris-profile.jpg";
import "./img/about/will-profile.jpg";
import "./img/about/laura-profile.jpg";

import "./img/campaigns/ben-haynes.jpg";
import "./img/campaigns/heather-ledoux.jpg";
import "./img/campaigns/maria-mclaughlin.jpg";
import "./img/campaigns/suzy-montero.jpg";

// Import foundation stuff.
import "foundation-sites/js/foundation.core";
import "foundation-sites/js/foundation.util.mediaQuery";
import "foundation-sites/js/foundation.util.motion";
import "foundation-sites/js/foundation.util.triggers";
import "foundation-sites/js/foundation.responsiveMenu";
import "foundation-sites/js/foundation.responsiveToggle";
import "foundation-sites/js/foundation.toggler";

import "motion-ui";
// import 'jquery-parallax.js';
import "jquery-mask-plugin";

import components from "./components/index";

$(document).ready($ => {
  $(document).foundation();
  components($);
  $("body").removeClass("no-js");

  // $('.home-section .home-background').parallax({
  //   imageSrc: hero_path,
  //   position: 'center bottom'
  // });
  //
});
