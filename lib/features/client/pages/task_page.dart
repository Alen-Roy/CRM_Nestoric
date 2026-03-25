import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<DateTime> dates = [];
    for (int i = 0; i < 60; i++) {
      dates.add(DateTime.now().add(Duration(days: i)));
    }
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
                            print(DateFormat('EEE').format(dates[index]));
                          },
                          child: Container(
                            height: 80,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  style: TextStyle(color: Colors.black),
                                  dates[index].day.toString(),
                                ),
                                Text(
                                  style: TextStyle(color: Colors.white60),
                                  DateFormat('EEE').format(dates[index]),
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
            ],
          ),
        ),
      ),
    );
  }
}
