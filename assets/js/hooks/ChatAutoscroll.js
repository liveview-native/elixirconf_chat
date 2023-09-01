export const ChatAutoscroll = {
  lastScrollDirection: "down",
  lastScrollTop: 0,
  scrollListener: null,
  mounted() {
    this.scrollListener = this.el.addEventListener("scroll", e => {
      let scrollTop = this.el.scrollTop;

      if (this.lastScrollTop >= scrollTop) {
        this.lastScrollDirection = "up";
      } else {
        this.lastScrollDirection = "down";
      };
      this.lastScrollTop = scrollTop;
    });
    this.el.scrollTo(0, this.el.scrollHeight);
  },
  updated() {
    if (this.lastScrollDirection == "down") {
      this.el.scrollTo(0, this.el.scrollHeight);
    }
  },
  destroyed() {
    this.el.removeEventListener("scroll", this.scrollListener);
    this.scrollListener = null;
  }
}