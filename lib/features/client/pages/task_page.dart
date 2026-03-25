import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  int selectedIndex = 0;
  late List<DateTime> dates;

  @override
  void initState() {
    super.initState();
    dates = [];
    for (int i = 0; i < 60; i++) {
      dates.add(DateTime.now().add(Duration(days: i)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color taskslidercolor = Colors.white12;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Task Page",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),

              SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  itemCount: dates.length,

                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Container(
                            height: 80,
                            width: 50,
                            decoration: BoxDecoration(
                              color: selectedIndex == index
                                  ? taskslidercolor
                                  : Colors.white54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dates[index].day.toString(),
                                  style: TextStyle(
                                    color: selectedIndex == index
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEE').format(dates[index]),
                                  style: TextStyle(
                                    color: selectedIndex == index
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Text(
                selectedIndex == 0
                    ? "Today"
                    : DateFormat("EEEE").format(dates[selectedIndex]),
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(),
            ],
          ),
        ),
      ),
    );
  }
}
