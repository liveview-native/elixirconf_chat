/* If input is a textarea, allow enter key to submit form */
/* Line breaks will use shift + enter */
export const TextareaEnterSubmit = {
  mounted() {
    this.el.addEventListener("keydown", e => {
      if (e.key == "Enter" && !e.shiftKey) {
        this.el.form.dispatchEvent(
          new Event("submit", {bubbles: true, cancelable: true}));
      }
    })
  }
}
