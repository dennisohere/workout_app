

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

abstract class Detector {

  Future<void> detectWorkoutPose({required InputImage inputImage, required Function(bool) onPoseFound, required Function(List<Pose>) onProcessedImage});

}