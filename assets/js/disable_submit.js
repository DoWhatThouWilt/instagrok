export default DisableSubmit = {
  mounted() {
    let submit = document.getElementById("submit")
    this.el.addEventListener("input", e => {
      if (this.el.value === "") {
        submit.disabled = true
      } else {
        submit.disabled = false
      }
    })
  }
}
