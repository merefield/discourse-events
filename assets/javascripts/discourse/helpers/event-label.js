import { helperContext } from "discourse-common/lib/helpers";
import { htmlSafe } from "@ember/template";
import { eventLabel } from "../lib/date-utilities";

export default function _eventLabel(event, args) {
  let siteSettings = helperContext().siteSettings;
  return htmlSafe(eventLabel(event, Object.assign({}, args, { siteSettings })));
};
