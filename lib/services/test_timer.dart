import 'package:flutter/material.dart';
import 'dart:async';

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;

  ElapsedTime({
    this.hundreds,
    this.seconds,
    this.minutes,
  });
}

class Dependencies {
  final List<ValueChanged<ElapsedTime>> timerListeners = <ValueChanged<ElapsedTime>>[];
  final Stopwatch stopwatch =  Stopwatch();
  final int timerMillisecondsRefreshRate = 30;
}

class TimerPage extends StatefulWidget {
  final Dependencies dependencies;
  TimerPage(this.dependencies);

  TimerPageState createState() =>  TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  final Dependencies dependencies =  Dependencies();

  void leftButtonPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        print("${dependencies.stopwatch.elapsedMilliseconds}");
      } else {
        dependencies.stopwatch.reset();
      }
    });
  }

  void rightButtonPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.stop();
      } else {
        dependencies.stopwatch.start();
      }
    });
  }

  Widget buildFloatingButton(String text, VoidCallback callback) {
    return new GestureDetector(
      child: new Text(text),
      onLongPress: (){
        setState(() {
          dependencies.stopwatch.start();
        });
      },
      onLongPressUp: (){
        dependencies.stopwatch.stop();
      },
      // onPressed: callback
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Image.asset("assets/record.gif", width: 10, height: 10,),
          new Expanded(
            child: new TimerText(dependencies: widget.dependencies),
          )
        ],
      ),
    );
  }
}

class TimerText extends StatefulWidget {
  TimerText({this.dependencies});
  final Dependencies dependencies;

  TimerTextState createState() => new TimerTextState(dependencies: dependencies);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({this.dependencies});
  final Dependencies dependencies;
  Timer timer;
  int milliseconds;

  @override
  void initState() {
    timer = new Timer.periodic(new Duration(milliseconds: dependencies.timerMillisecondsRefreshRate), callback);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      milliseconds = dependencies.stopwatch.elapsedMilliseconds;
      final int hundreds = (milliseconds / 10).truncate();
      final int seconds = (hundreds / 100).truncate();
      final int minutes = (seconds / 60).truncate();
      final ElapsedTime elapsedTime = new ElapsedTime(
        hundreds: hundreds,
        seconds: seconds,
        minutes: minutes,
      );
      for (final listener in dependencies.timerListeners) {
        listener(elapsedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
          new MinutesAndSeconds(dependencies: dependencies),
          new Hundreds(dependencies: dependencies),
      ],
    );
  }
}

class MinutesAndSeconds extends StatefulWidget {
  MinutesAndSeconds({this.dependencies});
  final Dependencies dependencies;

  MinutesAndSecondsState createState() => new MinutesAndSecondsState(dependencies: dependencies);
}

class MinutesAndSecondsState extends State<MinutesAndSeconds> {
  MinutesAndSecondsState({this.dependencies});
  final Dependencies dependencies;

  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.minutes != minutes || elapsed.seconds != seconds) {
      setState(() {
        minutes = elapsed.minutes;
        seconds = elapsed.seconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return new Text('$minutesStr:$secondsStr.');
  }
}

class Hundreds extends StatefulWidget {
  Hundreds({this.dependencies});
  final Dependencies dependencies;

  HundredsState createState() => new HundredsState(dependencies: dependencies);
}

class HundredsState extends State<Hundreds> {
  HundredsState({this.dependencies});
  final Dependencies dependencies;

  int hundreds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.hundreds != hundreds) {
      setState(() {
        hundreds = elapsed.hundreds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    return new Text(hundredsStr);
  }
}
