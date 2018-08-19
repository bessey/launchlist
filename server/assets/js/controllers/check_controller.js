import { Controller } from "stimulus";

export default class CheckController extends Controller {
  static targets = ["form"];

  submit(e) {
    this.formTarget.submit();
  }
}
