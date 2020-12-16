extension StringExtension on String {
  String capitalize() {
    if (this == null) {
      return this;
      // throw new ArgumentError("string: $this");
    }
    if (this.length == 0) {
      return this;
    }
    return this[0].toUpperCase() + this.substring(1);
  }
}
