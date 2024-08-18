// import ModalFunctionality from "discourse/mixins/modal-functionality";
import Component from "@glimmer/component";
import I18n from "I18n";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class AddEventModalComponent extends Component {
  @service siteSettings;
  title = "add_event.modal_title";
  @tracked bufferedEvent = null;
  @tracked valid = false;

  @action
  clear(event) {
    event?.preventDefault();
    this.bufferedEvent = null;
  }

  @action
  saveEvent() {
    if (this.valid) {
      this.args.model.update(this.bufferedEvent);
      this.send("closeModal");
    } else {
      this.flash(I18n.t("add_event.error"), "error");
    }
  }

  @action
  updateEvent(event, valid) {
    this.bufferedEvent = event;
    this.valid = valid;
  }
}

// import { action, computed } from "@ember/object";
// import { inject as service } from "@ember/service";
// import I18n from "I18n";

