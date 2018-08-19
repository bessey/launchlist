import { Controller } from "stimulus";

export default class CheckController extends Controller {
  static targets = ["form", "checkbox"];

  toggleAndSubmit() {
    this.checkboxTarget.checked = !this.checkboxTarget.checked;
    this.submit();
  }

  submit() {
    fetch(this.formTarget.action, {
      body: new FormData(this.formTarget),
      method: "POST"
    }).then(response => response.text());
  }
}
