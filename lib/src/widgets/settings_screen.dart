import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xff0096ce),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff204b5e),
              Color(0xff5d97a2),
            ],
          ),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: Colors.white,
            fontSize: Settings.fontSize,
            fontFamily: 'PressStart2P',
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.extension,
                          color: Colors.white,
                        ),
                        Text(' '),
                        Text('Score'),
                      ],
                    ),
                    Switch(
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.grey,
                      value: Settings.showScore,
                      onChanged: (bool value) {
                        setState(() {
                          Settings.showScore = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.music_note,
                          color: Colors.white,
                        ),
                        Text(' '),
                        Text('Music'),
                      ],
                    ),
                    Switch(
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.grey,
                      value: Settings.musicEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          Settings.musicEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.queue_music_outlined,
                          color: Colors.white,
                        ),
                        Text(' '),
                        Text('Volume'),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white54,
                        thumbColor: Colors.white,
                        overlayColor: Colors.white24,
                        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: Settings.volumeProc,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: Settings.volumeProc.round().toString(),
                        onChanged: Settings.musicEnabled
                            ? (double value) {
                          setState(() {
                            Settings.volumeProc = value;
                          });
                        }
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.font_download,
                          color: Colors.white,
                        ),
                        Text(' '),
                        Text('Font Size'),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white54,
                        thumbColor: Colors.white,
                        overlayColor: Colors.white24,
                        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: Settings.fontSize,
                        min: 10,
                        max: 30,
                        divisions: 20,
                        label: Settings.fontSize.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            Settings.fontSize = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.language,
                          color: Colors.white,
                        ),
                        Text(' '),
                        Text('Language'),
                      ],
                    ),
                    DropdownButton<String>(
                      dropdownColor: const Color(0xff204b5e),
                      value: Settings.language,
                      items: <String>['Polish', 'English'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          Settings.language = newValue!;
                        });
                      },
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Save Settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class Settings {
  static bool musicEnabled = true;
  static bool showScore = true;
  static double volume = 0.5;
  static double fontSize = 16;
  static String language = 'Polish';

  static double get volumeProc {
    return volume*100;
  }
  static set volumeProc(double value) {
    volume = value/100;
  }
}