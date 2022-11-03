import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="annotable"
export default class extends Controller {
  connect() {
    console.log('Connecting annotable!');
    this.setPatientCol()
    this.setEventCol()
    this.setBlInterval()
    this.setFuInterval()
  }

  select_column(field_id) {
    const el    = document.getElementById(field_id);
    const color = el.getAttribute('data-col-color');
    const sel   = document.getElementById('preview-table').querySelectorAll(`[data-col="${el.value}"]`)
    for (const s of sel) {
      s.classList.add(color);
    }
    const sel2  = document.getElementById('preview-table').querySelectorAll(`:not([data-col="${el.value}"])`)
    for (const s of sel2) {
      s.classList.remove(color);
    }
  }

  // document.getElementById('preview-table').querySelectorAll(`[data-col="1"]`).length  => 16
  // document.getElementById('preview-table').querySelectorAll(`table#preview-table [data-col="1"]`).length  => 16
  // document.querySelectorAll(`table#preview-table [data-col="1"]`).length  => 16

  // document.getElementById('preview-table').querySelectorAll(`table#preview-table :not([data-col="1"])`).length
  // document.querySelectorAll(`table#preview-table :not([data-col="1"])`).length


  select_interval(field_id) {
    const el    = document.getElementById(field_id);
    const color = el.getAttribute('data-col-color');
    const interval = this.stringToList(el.value)

    const sel2   = document.getElementById('preview-table').querySelectorAll('[data-col]')
    for (const s of sel2) {
      s.classList.remove(color);
    }

    for (const col of interval) {
      const sel   = document.getElementById('preview-table').querySelectorAll(`[data-col="${col}"]`)
      for (const s of sel) {
        s.classList.add(color);
      }
    }
  }

  setPatientCol() {
    this.select_column('page_patient_col')
  }

  setEventCol() {
    console.log('test');
    this.select_column('page_event_col')
  }

  changePatientCol() {
    this.setPatientCol()
  }

  setBlInterval() {
    this.select_interval('page_baseline_intervals')
  }

  setFuInterval() {
    this.select_interval('page_follow_up_intervals')
  }

  myRange(n1, n2) {
    return Array.from({ length: n2 - n1 + 1 }, (_, i) => n1 + i)
  }

  notNil(i) { 
    return !(typeof i === 'undefined' || i === null || isNaN(i))
  }
  // const notNil = x => !(typeof i === 'undefined' || i === null || isNaN(i))

  stringToList(s) {
    let arr = s.split(",")
    arr = arr.map(x => x.split('-').map(y => parseInt(y.trim())).filter(i => this.notNil(i)) )
    arr = arr.map(x => {
      if (x.length==1) {
        return x[0]
      } else {
        return this.myRange(x[0], x[x.length-1])
      }
    })
    arr = arr.flat()
    return arr.filter(i => this.notNil(i))
  }
}
