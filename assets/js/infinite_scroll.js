InfiniteScroll = {
  page() {
    return parseInt(this.el.dataset.page);
  },
  loadMore(entries) {
    const target = entries[0];
    if (target.isIntersecting && this.pending == this.page()) {
      this.pending = this.page() + 1;
      this.pushEvent("load-posts", {
        ratio: target.intersectionRatio,
        page: this.page(),
        pending: this.pending
      });
    }
  },
  mounted() {
    this.pending = this.page();
    this.observer = new IntersectionObserver(
      (entries) => this.loadMore(entries),
      {
        root: null, // window by default
        rootMargin: "0px",
        threshold: 1,
      }
    );
    this.observer.observe(this.el);
  },
  beforeDestroy() {
    this.observer.unobserve(this.el);
  },
  updated() {
    this.pending = this.page();
  },
};

export default InfiniteScroll
