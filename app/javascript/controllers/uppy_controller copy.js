import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="uppy"
// It has nothing to do with the Uppy JS library
export default class extends Controller {
  static targets = [ "filenames", "input", "dropZone", "clickOrDrag" ]

  selectFile(e) {
    // console.log('click');
    this.inputTarget.click()
  }

  inputChange(ev) {
    this.updateFilenames(this.inputTarget.files)
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
    this.updateFilenames(e.dataTransfer.files)
    this.restoreDropZoneAspect()  
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
}
