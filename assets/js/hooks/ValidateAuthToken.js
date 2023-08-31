export const ValidateAuthToken = {
  mounted() {
    if (token = localStorage.getItem('auth_token')) {
      this.pushEvent("validate_token", { token: token });
    }
  }
}