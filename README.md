# README

Basic Ruby script wrapper that allow to perform a transformation on an input file.


Features:
- the wrapper is made with Ruby on Rails 7
- the script will be executed asynchronously
- the user can upload the file to be analysed/processed/converted through a web form
- the user will be informed of each step of the script execution (queued, start, step, error or completition) through a a websocket (thanks to Turbo Streams)
- in case of error, the relative message and the whole backtrace will be shown
- at the end of the process the user will be able to download the new file and delete from the system this file and the uploaded file
- the user does not need to authenticate (no autheintication mechanism is provided)
- each user is isolated from the others by the session. The loaded and created files are visible only to the owner


To be implemented:
- a periodic job that will delete files still present in system


## What the script do

By default REDCap export data of repeated events (eg patients follow ups) on single lines. The current script reorganize the data table in order to have only a row for every patient/participant, the repeated events will be fixed side by side. 


## Articles

https://rubydoc.org/github/hotwired/turbo-rails/main/Turbo%2FStreamsHelper:turbo_stream_from

https://www.honeybadger.io/blog/chat-app-rails-actioncable-turbo/

https://www.colby.so/posts/turbo-streams-on-rails

https://turbo.hotwired.dev/handbook/streams


## Docker

A Docker image was created, you can find it [here](https://hub.docker.com/r/iwan/redcap_out_converter).

Run the container:
```
docker pull iwan/redcap_out_converter
docker run -p 3003:3003 iwan/redcap_out_converter
```

And access the site [here](http://localhost:3003/)


### Dockerfile

I added `gcompat` lib to Dockerfile in order to avoid a problem with the nokogiri gem [see here](https://stackoverflow.com/questions/70963924/unable-to-load-nokogiri-in-docker-container-on-m1-mac)
