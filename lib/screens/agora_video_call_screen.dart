import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraVideoCallScreen extends StatefulWidget {
  const AgoraVideoCallScreen({super.key});

  @override
  State<AgoraVideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<AgoraVideoCallScreen> {
  RtcEngine? _engine; // Non-late to avoid initialization errors
  bool _isMuted = false;
  bool _isVideoOn = true;
  bool _isScreenSharing = false;
  int? _remoteUid;
  String? _errorMessage;
  static const String _appId =
      'f3881ca66baf4aa7bdd71147966301ad'; // Replace with your Agora App ID
  static const String _channel = 'demo-channel';
  static const int _uid = 0;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    try {
      // Request permissions first
      await _requestPermissions();

      // Initialize Agora engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        const RtcEngineContext(
          appId: _appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      // Register event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print('Joined channel: ${connection.channelId}');
            setState(() {});
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print('User joined: $remoteUid');
            setState(() => _remoteUid = remoteUid);
          },
          onUserOffline:
              (
                RtcConnection connection,
                int remoteUid,
                UserOfflineReasonType reason,
              ) {
                print('User offline: $remoteUid');
                setState(() => _remoteUid = null);
              },
          onError: (ErrorCodeType err, String msg) {
            print('Agora Error: $err - $msg');
            setState(() => _errorMessage = 'Agora Error: $msg');
          },
        ),
      );

      // Enable video and join channel
      await _engine!.enableVideo();
      await _engine!.startPreview();
      await _engine!.joinChannel(
        token: '', // Empty for demo (use token in production)
        channelId: _channel,
        uid: _uid,
        options: const ChannelMediaOptions(
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
      );
    } catch (e) {
      print('Initialization Error: $e');
      setState(() => _errorMessage = 'Failed to initialize video call: $e');
    }
  }

  Future<void> _requestPermissions() async {
    final status = await [Permission.camera, Permission.microphone].request();
    if (status[Permission.camera]!.isDenied ||
        status[Permission.microphone]!.isDenied) {
      setState(
        () => _errorMessage = 'Camera and microphone permissions required',
      );
      openAppSettings();
    }
  }

  Future<void> _toggleAudio() async {
    if (_engine == null) {
      setState(() => _errorMessage = 'Video engine not initialized');
      return;
    }
    try {
      await _engine!.muteLocalAudioStream(!_isMuted);
      setState(() => _isMuted = !_isMuted);
    } catch (e) {
      setState(() => _errorMessage = 'Audio toggle error: $e');
    }
  }

  Future<void> _toggleVideo() async {
    if (_engine == null) {
      setState(() => _errorMessage = 'Video engine not initialized');
      return;
    }
    try {
      await _engine!.muteLocalVideoStream(!_isVideoOn);
      await _engine!.enableLocalVideo(!_isVideoOn);
      setState(() => _isVideoOn = !_isVideoOn);
    } catch (e) {
      setState(() => _errorMessage = 'Video toggle error: $e');
    }
  }

  Future<void> _startScreenShare() async {
    if (_engine == null) {
      setState(() => _errorMessage = 'Video engine not initialized');
      return;
    }
    try {
      if (_isScreenSharing) {
        // Stop screen sharing
        await _engine!.stopScreenCapture();
        await _engine!.updateChannelMediaOptions(
          const ChannelMediaOptions(
            publishScreenTrack: false,
            publishCameraTrack: true,
          ),
        );
        await _engine!.startPreview();
        setState(() => _isScreenSharing = false);
      } else {
        // Start screen sharing
        const parameters = ScreenCaptureParameters2(
          captureVideo: true,
          // videoParams: VideoEncodingPreference(
          //   width: 1280,
          //   height: 720,
          //   frameRate: 15,
          //   bitrate: 1000,
          // ),
          captureAudio: true,
          audioParams: ScreenAudioParameters(
            sampleRate: 44100,
            channels: 2,
            captureSignalVolume: 100,
          ),
        );
        await _engine!.startScreenCapture(parameters);
        await _engine!.updateChannelMediaOptions(
          const ChannelMediaOptions(
            publishScreenTrack: true,
            publishCameraTrack: false,
          ),
        );
        setState(() => _isScreenSharing = true);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Screen share error: $e');
    }
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: Stack(
        children: [
          // Error message (if any)
          if (_errorMessage != null)
            Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          // Remote video
          if (_remoteUid != null && _engine != null)
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine!,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: const RtcConnection(channelId: _channel),
              ),
            ),
          // Local video or screen
          if (_engine != null)
            Positioned(
              bottom: 20,
              right: 20,
              width: 120,
              height: 160,
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine!,
                  canvas: VideoCanvas(
                    uid: _uid,
                    sourceType: _isScreenSharing
                        ? VideoSourceType.videoSourceScreen
                        : VideoSourceType.videoSourceCamera,
                  ),
                ),
              ),
            ),
          // Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _engine != null ? _toggleAudio : null,
                    child: Text(_isMuted ? 'Unmute' : 'Mute'),
                  ),
                  ElevatedButton(
                    onPressed: _engine != null ? _toggleVideo : null,
                    child: Text(_isVideoOn ? 'Video Off' : 'Video On'),
                  ),
                  ElevatedButton(
                    onPressed: _engine != null ? _startScreenShare : null,
                    child: Text(
                      _isScreenSharing ? 'Stop Share' : 'Share Screen',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
