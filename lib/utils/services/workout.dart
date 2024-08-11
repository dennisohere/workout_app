import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gainz/domain/entities/workout_session/workout_session.dart';
import 'package:gainz/domain/repositories/workout_session_repository.dart';
import 'package:gainz/domain/usecases/workout.dart';
import 'package:gainz/utils/di/injector.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../presentation/widgets/pose_painter.dart';

class WorkoutService {
  CameraController? _controller;
  PoseDetector? _poseDetector;
  bool _started = false;
  int _repCount = 0;
  List<bool> _bodyMovements = [];
  List<bool> _legsCycle = [];
  DateTime? _startedAt;
  DateTime? _endedAt;

  late CameraDescription _selectedCamera;

  PoseDetector? get poseDetector => _poseDetector;

  int get repCount => _repCount;

  List<bool> get bodyMovements => _bodyMovements;

  List<bool> get legsCycle => _legsCycle;

  CameraController? get controller => _controller;

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  final Function(int) onCountUpdated;
  final Function(CustomPaint) onPaintUpdated;
  final Function(CameraController) onReady;
  final Function(bool) onWorkoutStarted;

  WorkoutService({
    required this.onCountUpdated,
    required this.onPaintUpdated,
    required this.onReady,
    required this.onWorkoutStarted,
  }) {
    _initializeCameraController();
  }

  Future toggleWorkout() async {
    if (_started) {
      stopWorkout();
    } else {
      startWorkout();
    }
    onWorkoutStarted.call(_started);
  }

  Future stopWorkout() async {
    _started = false;
    _endedAt = DateTime.now();
    _controller!.stopImageStream();
    await _saveWorkout();
  }

  Future startWorkout() async {
    _started = true;
    _startedAt = DateTime.now();
    _repCount = 0;
    onCountUpdated(0);
    _controller!.startImageStream(_onImageAvailable);
    debugPrint('rep started!!!!!!!!');
  }

  dispose() {
    poseDetector?.close();
    controller?.dispose();
  }

  Future _saveWorkout() async {
    final workoutSession = WorkoutSessionEntity(
      repCount: _repCount,
      startedAt: _startedAt!,
      secondsElapsed: _endedAt!.difference(_startedAt!).inSeconds,
    );

    final repository = Injector.resolve<WorkoutSessionRepository>();

    WorkoutUseCases(repository).saveWorkout(workoutSession);
  }

  Future _initializeCameraController() async {
    final List<CameraDescription> cameras = await availableCameras();
    _selectedCamera = cameras.last;

    _controller = CameraController(
      _selectedCamera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // for Android
          : ImageFormatGroup.bgra8888, // for iOS
    );
    _controller!.initialize().then((_) {
      onReady.call(_controller!);
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  _detectHandsMovement(Pose pose) {
    bool cycleComplete = false;
    final rightWristLandmark = pose.landmarks[PoseLandmarkType.rightWrist];
    final rightEyeLandmark = pose.landmarks[PoseLandmarkType.rightEye];

    final leftWristLandmark = pose.landmarks[PoseLandmarkType.leftWrist];
    final leftEyeLandmark = pose.landmarks[PoseLandmarkType.leftEye];

    bool rightHandUp = rightWristLandmark!.y < rightEyeLandmark!.y;
    bool leftHandUp = leftWristLandmark!.y < leftEyeLandmark!.y;

    final allHandsUp = rightHandUp && leftHandUp;

    final rightKneeLandmark = pose.landmarks[PoseLandmarkType.rightKnee];
    final leftKneeLandmark = pose.landmarks[PoseLandmarkType.leftKnee];

    final kneeDistance =
        _computeDistance(point2: leftKneeLandmark!, point1: rightKneeLandmark!)
            .toInt();

    final kneesApart = kneeDistance >= 140;

    final bodyMoved = kneesApart && allHandsUp;

    if (bodyMovements.isNotEmpty) {
      if (bodyMovements.last != bodyMoved) {
        cycleComplete = true;
        bodyMovements.add(bodyMoved);
      }
    } else {
      bodyMovements.add(bodyMoved);
    }

    return cycleComplete;
  }

  double _computeDistance(
      {required PoseLandmark point1, required PoseLandmark point2}) {
    // Distance = √[(x₂ - x₁)² + (y₂ - y₁)² ]
    final dx = point1.x - point2.x;
    final dy = point1.y - point2.y;
    return sqrt((dx * dx) + (dy * dy));
  }

  _detectWorkout(List<Pose> poses) {
    for (Pose pose in poses) {
      final handsDetected = _detectHandsMovement(pose);

      if (handsDetected) {
        _updateCounter();
      }
    }
  }

  _updateCounter() {
    _repCount = bodyMovements.length ~/ 2;
    onCountUpdated.call(repCount);
  }

  _onImageAvailable(CameraImage image) async {
    final inputImage = await _initInputImage(image);
    final options = PoseDetectorOptions();
    _poseDetector = PoseDetector(options: options);

    // Logger().d(['input image', inputImage]);

    if (inputImage == null) return null;
    if (_poseDetector == null) return null;

    final List<Pose> poses = await _poseDetector!.processImage(inputImage);

    _detectWorkout(poses);

    final painter = PosePainter(poses, inputImage.metadata!.size,
        inputImage.metadata!.rotation, _selectedCamera.lensDirection);

    onPaintUpdated.call(CustomPaint(painter: painter));
  }

  Future<InputImage?> _initInputImage(CameraImage image) async {
    final sensorOrientation = _selectedCamera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (_selectedCamera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS

    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }
}
