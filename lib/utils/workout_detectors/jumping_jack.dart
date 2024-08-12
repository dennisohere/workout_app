
import 'dart:math';

import 'package:gainz/utils/workout_detectors/detector.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:logger/logger.dart';

class JumpingJackDetector implements Detector{
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());

  bool poseFound = false;

  double _computeDistance(
      {required PoseLandmark point1, required PoseLandmark point2}) {
    // Distance = √[(x₂ - x₁)² + (y₂ - y₁)² ]
    final dx = point1.x - point2.x;
    final dy = point1.y - point2.y;
    final dz = point1.z - point2.z;
    return sqrt((dx * dx) + (dy * dy) + (dz * dz));
  }


  bool areFeetApart(Pose pose){
    final rightFeetLandmark = pose.landmarks[PoseLandmarkType.rightHeel];
    final leftFeetLandmark = pose.landmarks[PoseLandmarkType.leftHeel];

    final kneeDistance =
    _computeDistance(point1: rightFeetLandmark!, point2: leftFeetLandmark!)
        .toInt();

    final feetApart = kneeDistance >= 120;

    return feetApart;
  }

  bool areAllHandsUp(Pose pose){
    final rightWristLandmark = pose.landmarks[PoseLandmarkType.rightWrist];
    final rightEyeLandmark = pose.landmarks[PoseLandmarkType.rightEye];

    final leftWristLandmark = pose.landmarks[PoseLandmarkType.leftWrist];
    final leftEyeLandmark = pose.landmarks[PoseLandmarkType.leftEye];

    bool rightHandUp = rightWristLandmark!.y < rightEyeLandmark!.y;
    bool leftHandUp = leftWristLandmark!.y < leftEyeLandmark!.y;

    final allHandsUp = rightHandUp && leftHandUp;

    return allHandsUp;
  }

  Future<bool?> analysePose(Pose pose) async {

    final feetApart = areFeetApart(pose);
    final allHandsUp = areAllHandsUp(pose);

    final found = feetApart && allHandsUp;

    if(found != poseFound){
      poseFound = found;
      return found;
    }

    return null;
  }

  @override
  Future<void> detectWorkoutPose({required InputImage inputImage, required Function(bool) onPoseFound, required Function(List<Pose>) onProcessedImage}) async {
    final List<Pose> poses = await _poseDetector.processImage(inputImage);

    onProcessedImage.call(poses);

    for(final pose in poses){
      final found = await analysePose(pose);

      onPoseFound.call(found == true);
    }

  }

  dispose(){
    _poseDetector.close();
  }
}
