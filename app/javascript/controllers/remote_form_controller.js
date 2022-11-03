import Rails from "@rails/ujs";
import debounce from "debounce";
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="remote-form"
export default class extends Controller {
  initialize() {
    this.submit = debounce(this.submit.bind(this), 300) 
  }

  static targets = ["form"]

  submit() {
    console.log('submit!');
    Rails.fire(this.formTarget, 'submit')
  }
}
