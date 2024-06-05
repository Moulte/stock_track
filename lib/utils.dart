  List<List<T>> splitList<T>(List<T> list, int n) {
    int length = list.length;
    int partSize = (length / n).ceil();
    List<List<T>> parts = [];

    for (int i = 0; i < length; i += partSize) {
      int end = (i + partSize < length) ? i + partSize : length;
      parts.add(list.sublist(i, end));
    }

    return parts;
  }