// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import AnnotableController from "./annotable_controller"
application.register("annotable", AnnotableController)

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import RemoteFormController from "./remote_form_controller"
application.register("remote-form", RemoteFormController)

import UppyController from "./uppy_controller"
application.register("uppy", UppyController)
