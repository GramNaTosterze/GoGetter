import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicEnabled = true;
  double volume = 50;
  double fontSize = 16;
  String difficulty = 'Normal';

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
            fontSize: fontSize,
            fontFamily: 'PressStart2P',
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Music'),
                    Switch(
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.grey,
                      value: musicEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          musicEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Suwak głośności
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Volume'),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white54,
                        thumbColor: Colors.white,
                        overlayColor: Colors.white24,
                        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: volume,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: volume.round().toString(),
                        onChanged: musicEnabled
                            ? (double value) {
                          setState(() {
                            volume = value;
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
                    const Text('Font Size'),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white54,
                        thumbColor: Colors.white,
                        overlayColor: Colors.white24,
                        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: fontSize,
                        min: 10,
                        max: 30,
                        divisions: 20,
                        label: fontSize.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            fontSize = value;
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
                    const Text('Language'),
                    DropdownButton<String>(
                      dropdownColor: const Color(0xff204b5e), // Kolor tła rozwijanego menu
                      value: difficulty,
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
                          difficulty = newValue!;
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
