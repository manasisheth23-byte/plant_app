class WorkOrderItem {
  final String workOrderNo;
  final String mid;

  WorkOrderItem({required this.workOrderNo, required this.mid});

  factory WorkOrderItem.fromJson(Map<String, dynamic> json) {
    return WorkOrderItem(
      workOrderNo: json["WORKORDERNO"].toString(),
      mid: json["MID"].toString(),
    );
  }
}
