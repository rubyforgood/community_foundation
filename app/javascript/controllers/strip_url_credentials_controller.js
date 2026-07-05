import { Controller } from "@hotwired/stimulus"

// Strips HTTP Basic-Auth credentials from the URL (e.g. https://user:pass@host).
// The user:pass@ form makes document.URL mismatch the credential-free URL Turbo
// passes to history.replaceState(), throwing a SecurityError that breaks the page.
// The browser has already cached the credentials, so the clean navigation below
// stays authenticated.
export default class extends Controller {
  connect() {
    const url = new URL(window.location.href)
    if (url.username || url.password) {
      url.username = ""
      url.password = ""
      window.location.replace(url.toString())
    }
  }
}
