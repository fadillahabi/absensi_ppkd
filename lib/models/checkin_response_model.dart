class CheckInResponse {
  final String message;
  final CheckInData data;

  CheckInResponse({required this.message, required this.data});

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      message: json['message'],
      data: CheckInData.fromJson(json['data']),
    );
  }
}

class CheckInData {
  final String attendanceDate;
  final String checkInTime;
  final double checkInLat;
  final double checkInLng;
  final String checkInAddress;
  final String status;

  CheckInData({
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkInLat,
    required this.checkInLng,
    required this.checkInAddress,
    required this.status,
  });

  factory CheckInData.fromJson(Map<String, dynamic> json) {
    return CheckInData(
      attendanceDate: json['attendance_date'],
      checkInTime: json['check_in_time'],
      checkInLat: json['check_in_lat'].toDouble(),
      checkInLng: json['check_in_lng'].toDouble(),
      checkInAddress: json['check_in_address'],
      status: json['status'],
    );
  }
}
