class Room {
  final int id;
  final String roomnumber;
  final String roomtype;
  final double pricepernight;
  final double officepricepernight;
  final String frontimage;
  final String status;

  const Room({
    required this.id,
    required this.roomnumber,
    required this.roomtype,
    required this.pricepernight,
    required this.officepricepernight,
    required this.frontimage,
    required this.status,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      roomnumber: json['roomnumber'] ?? 'Unnamed Room',
      roomtype: json['roomtype'] ?? 'Unknown Type',
      pricepernight: (json['pricepernight'] != null)
          ? double.tryParse(json['pricepernight'].toString()) ?? 0.0
          : 0.0,
      officepricepernight: (json['officepricepernight'] != null)
          ? double.tryParse(json['officepricepernight'].toString()) ?? 0.0
          : 0.0,
      frontimage: json['frontimage'] ?? 'Unknown Image',
      status: (json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomnumber': roomnumber,
      'roomtype': roomtype,
      'pricepernight': pricepernight,
      'officepricepernight': officepricepernight,
      'frontimage': frontimage,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'Room(id: $id, roomnumber: $roomnumber, roomtype: $roomtype, pricepernight: $pricepernight, officepricepernight: $officepricepernight, frontimage: $frontimage, status: $status)';
  }
}
