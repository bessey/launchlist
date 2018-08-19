import { Controller } from "stimulus";

export default class CheckController extends Controller {
  static targets = ["form"];

  submit(e) {
    fetch(this.formTarget.action, {
      body: new FormData(this.formTarget),
      method: "POST"
    })
      .then(response => response.text())
      .then(body => eval(body));
  }
}
