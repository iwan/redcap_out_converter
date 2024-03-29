import Rails from "@rails/ujs";
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="uppy"
// It has nothing to do with the Uppy JS library
export default class extends Controller {
  static targets = [ "filenames", "input", "dropZone", "clickOrDrag", "form" ]

  selectFile(e) {
    // console.log('click');
    this.inputTarget.click()
  }

  inputChange(ev) {
    this.updateFilename(this.inputTarget.files)
    // one file has been selected
    this.submit()
  }

  dragOver(e) {
    e.preventDefault()
    this.dropZoneTarget.classList.add("bg-gray-100")
  }

  dragLeave(e) {
    this.restoreDropZoneAspect()
  }

  dragEnd(e) {
    this.restoreDropZoneAspect()   
  }

  dropFiles(e) {
    e.preventDefault()
    this.updateFilename(e.dataTransfer.files)
    this.restoreDropZoneAspect()

    this.inputTarget.files = e.dataTransfer.files // only the last will be loaded
    // one file has been dropped
    this.submit()
  }

  restoreDropZoneAspect() {
    this.dropZoneTarget.classList.remove("bg-gray-100")
  }

  inputClick(e) {
    e.stopPropagation()
    // then will open window...
  }

  // connect() {
  // }


  updateFilenames(files) {
    let str = ""
    if (files.length) {
      str = [...files].map(file => file.name).join(", ")
    }
    this.filenamesTarget.innerHTML = str
  }

  updateFilename(files) {
    let str = ""
    if (files.length) {
      str = files.item(files.length-1).name
    } else {
      str = ""
    }
    this.filenamesTarget.innerHTML = str
  }


  submit() {
    Rails.fire(this.formTarget, 'submit')
  }
}
