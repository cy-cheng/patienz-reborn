# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Google Generative AI
pin "@google/generative-ai", to: "https://cdn.jsdelivr.net/npm/@google/generative-ai@0.16.0/+esm"
