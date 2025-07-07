# Pin npm packages by running ./bin/importmap

pin "application"
pin "bootstrap", to: "https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.esm.min.js"
pin "@popperjs/core", to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/esm/index.js"

pin_all_from "app/javascript/controllers", under: "controllers"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
