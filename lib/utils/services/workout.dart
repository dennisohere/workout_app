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
import 'package:logger/logger.dart';

import '../../presentation/widgets/pose_painter.dart';
import '../workout_detectors/jumping_jack.dart';

enum WorkoutState {
  waiting, // period to wait for pose detection to fully kick in
  started,
  ready,
  stopped
}

class WorkoutService {
  CameraController? _controller;
  bool _started = false;
  int _repCount = 0;

  DateTime? _startedAt;
  DateTime? _endedAt;
  final int waitTimeInSeconds;
  JumpingJackDetector detector = JumpingJackDetector();

  late CameraDescription _selectedCamera;

  int get repCount => _repCount;

  // List<bool> get bodyMovements => _bodyMovements;
  // List<bool> get legsCycle => _legsCycle;
  CameraController? get controller => _controller;

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  final Function(int) onCountUpdated;
  final Function(CustomPaint) onPaintUpdated;
  final Function(CameraController) onCameraReady;
  final Function(WorkoutState) onStateChanged;

  WorkoutService({
    required this.onCountUpdated,
    required this.onPaintUpdated,
    required this.onCameraReady,
    required this.onStateChanged,
    this.waitTimeInSeconds = 10,
  }) {
    _initializeCameraController();
  }

  Future toggleWorkout() async {
    if (_started) {
      stopWorkout();
    } else {
      startWorkout();
    }
  }

  Future stopWorkout() async {
    _started = false;
    _endedAt = DateTime.now();
    onStateChanged.call(WorkoutState.stopped);
    _controller!.stopImageStream();
    await _saveWorkout();
  }

  Future startWorkout() async {
    _repCount = 0;
    onCountUpdated.call(0);
    _controller!.startImageStream(_onImageAvailable);
    onStateChanged.call(WorkoutState.waiting);
    await Future.delayed(Duration(seconds: waitTimeInSeconds));

    _started = true;
    _startedAt = DateTime.now();

    onStateChanged.call(WorkoutState.started);

    debugPrint('rep started!!!!!!!!');
  }

  dispose() {
    detector.dispose();
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
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // for Android
          : ImageFormatGroup.bgra8888, // for iOS
    );
    _controller!.initialize().then((_) {
      onCameraReady.call(_controller!);
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

  _updateCounter() {
    _repCount++;
    onCountUpdated.call(_repCount);
  }

  _onImageAvailable(CameraImage image) async {
    final inputImage = await _initInputImage(image);

    if (inputImage == null) return null;

    await detector.detectWorkoutPose(
      inputImage: inputImage,
      onPoseFound: (isJumpingJack) {
        if (isJumpingJack) {
          _updateCounter();
        }
      },
      onProcessedImage: (poses) {
        final painter = PosePainter(poses, inputImage.metadata!.size,
            inputImage.metadata!.rotation, _selectedCamera.lensDirection);
        onPaintUpdated.call(CustomPaint(painter: painter));
      },
    );
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
