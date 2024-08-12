import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gainz/utils/services/workout.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late final WorkoutService workoutService;
  ValueNotifier<int> repCount = ValueNotifier(0);
  ValueNotifier<int> secondsElapsed = ValueNotifier(0);
  CameraController? controller;
  Timer? timer;
  WorkoutState workoutState = WorkoutState.stopped;
  bool get started => workoutState == WorkoutState.started;


  ValueNotifier<CustomPaint?> customPaintNotifier = ValueNotifier(null);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    workoutService = WorkoutService(
      onCountUpdated: (count){
        repCount.value = count;
      },
      onPaintUpdated: (paint){
        customPaintNotifier.value = paint;
      },
      onCameraReady: (camController){
        controller = camController;
        setState(() {});
      },
      onStateChanged: (state){
        setState(() {
          workoutState = state;
        });
        if(started){
          secondsElapsed.value = 0;
          repCount.value = 0;
          initTimer();
        } else {
          timer?.cancel();
        }
      }
    );
  }

  initTimer(){
    timer = Timer.periodic(const Duration(seconds: 1), (time){
      secondsElapsed.value++;
    });
  }




  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: Text('Waiting for camera...'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(
            controller!,
          ),
          ValueListenableBuilder(
              valueListenable: customPaintNotifier,
              builder: (_, customPaint, child) {
                if (customPaint == null || workoutState == WorkoutState.stopped) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: customPaint,
                );
              }),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                if(workoutState != WorkoutState.waiting) ...[
                  ValueListenableBuilder(valueListenable: repCount, builder: (_, count, child){
                    return Text('$count')
                        .fontSize(100)
                        .textColor(Colors.white)
                        .padding(all: 70)
                        .decorated(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                    );
                  }),

                  ValueListenableBuilder(valueListenable: secondsElapsed, builder: (_, elapsed, child){
                    return _RepTimer(secondsElapsed: elapsed, key: UniqueKey(),);
                  }),
                ],

                if(workoutState == WorkoutState.waiting) ...[
                  _WaitCountdown(waitTime: workoutService.waitTimeInSeconds),
                ],

                const SizedBox(
                  height: 20,
                ),


                OutlinedButton.icon(
                  onPressed: () async {
                    workoutService.toggleWorkout();
                  },
                  label: Text(started ? "Stop" : 'Start').fontSize(40),
                  icon: Icon(
                    started ? Icons.stop : Icons.play_arrow,
                    size: 50,
                  ),
                  style: ButtonStyle(
                    foregroundColor: const WidgetStatePropertyAll(Colors.white),
                    iconColor: WidgetStatePropertyAll(
                        started ? Colors.red : Colors.white),
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 50, vertical: 10)),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                FilledButton.icon(
                  onPressed: () {
                    context.router.back();
                  },
                  label: const Text('Exit').fontSize(30),
                  icon: const Icon(
                    Icons.close,
                    size: 40,
                  ),
                  style: ButtonStyle(
                    backgroundColor: const WidgetStatePropertyAll(Colors.red),
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 70, vertical: 10)),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    workoutService.dispose();
    super.dispose();
  }
}


class _RepTimer extends StatelessWidget {
  final int secondsElapsed;

  const _RepTimer({super.key, required this.secondsElapsed});

  @override
  Widget build(BuildContext context) {
    final seconds = secondsElapsed % 60;
    final minutes = secondsElapsed ~/ 60;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(minutes.toString().padLeft(2, '0')).fontSize(50).textColor(Colors.white),
        const SizedBox(width: 7,),
        const Text(':').fontSize(40).textColor(Colors.amberAccent),
        const SizedBox(width: 7,),
        Text(seconds.toString().padLeft(2, '0')).fontSize(50).textColor(Colors.white),
      ],
    );
  }
}


class _WaitCountdown extends StatefulWidget {
  final int waitTime;

  const _WaitCountdown({super.key, required this.waitTime,});

  @override
  State<_WaitCountdown> createState() => _WaitCountdownState();
}

class _WaitCountdownState extends State<_WaitCountdown> {
  late int count;
  late Timer timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    count = widget.waitTime;
    timer = Timer.periodic(const Duration(seconds: 1), (time){
      count--;
      if(count <= 0 ){
        timer.cancel();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Ready...$count')
            .fontSize(60)
            .textColor(Colors.white),
        const Text('Ensure your full body is visible on screen')
            .fontSize(25)
        .textColor(Colors.white)
        .textAlignment(TextAlign.center)
        .padding(all: 5)
            .backgroundColor(Colors.amber.shade800.withOpacity(0.9))
      ],
    )
        .padding(all: 50);
  }


  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

}
