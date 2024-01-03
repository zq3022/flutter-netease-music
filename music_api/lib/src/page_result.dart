/// 基础接口
class PageResult<T> {
  PageResult({required this.data, this.total = 0, this.hasMore = false});

  List<T> data;

  ///总记录数
  int total;

  /// 是否还有下一页
  bool hasMore;
}
