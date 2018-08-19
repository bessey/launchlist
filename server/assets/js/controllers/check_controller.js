import { Controller } from "stimulus";

export default class CheckController extends Controller {
  static targets = ["form", "checkbox"];

  toggleAndSubmit(event) {
    this.checkboxTarget.checked = !this.checkboxTarget.checked;
    this.submit(event);
  }

  submit(event) {
    const PJAX = window.PJAX;
    if (PJAX) {
      PJAX.loadUrl(this.formTarget.action, {
        // Don't scroll up on form submit
        scrollTo: false,
        requestOptions: {
          formData: new FormData(this.formTarget),
          requestMethod: "POST"
        }
      });
    } else {
      this.formTarget.submit();
    }
  }
}
