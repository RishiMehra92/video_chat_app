// import 'package:flutter/material.dart';
// import 'package:flutter_aws_chime/views/meeting.view.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_aws_chime/flutter_aws_chime.dart';
// import 'package:flutter_aws_chime/models/join_info.model.dart';
//
// class VideoCallScreen extends StatefulWidget {
//   const VideoCallScreen({super.key});
//
//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }
//
// class _VideoCallScreenState extends State<VideoCallScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//   }
//
//   Future<void> _requestPermissions() async {
//     await [Permission.camera, Permission.microphone].request();
//     if (await Permission.camera.isDenied || await Permission.microphone.isDenied) {
//       openAppSettings();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Hardcoded JoinInfo (in production, fetch from backend)
//     final joinInfo = JoinInfo(
//       MeetingInfo.fromJson({
//         'MeetingId': 'your-meeting-id',  // Replace with real
//         'ExternalMeetingId': 'ext-meeting-id',
//         'MediaRegion': 'us-east-1',
//         'MediaPlacement': {
//           "AudioFallbackUrl": "...",
//           "AudioHostUrl": "...",
//           // ... (fill from Chime backend setup)
//         },
//       }),
//       AttendeeInfo.fromJson({
//         "AttendeeId": "attendee-id",
//         "ExternalUserId": "ext-user-id",
//         "JoinToken": "join-token",
//       }),
//     );
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Video Call')),
//       body: MeetingView(joinInfo),
//     );
//   }
// }