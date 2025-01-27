import 'package:flutter/material.dart';
import 'weather_screen.dart';

class SelectDayPage extends StatefulWidget {
  final List<String> availableDates;

  SelectDayPage({required this.availableDates});

  @override
  _SelectDayPageState createState() => _SelectDayPageState();
}

class _SelectDayPageState extends State<SelectDayPage> {
  String? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Date',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please select a date to view the weather forecast',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              _buildDateDropdown(widget.availableDates),
              SizedBox(height: 40),
              _buildViewWeatherButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateDropdown(List<String> availableDates) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent, width: 2),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        hint: Text(
          'Select a date',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
        isExpanded: true,
        value: selectedDate,
        items: availableDates.map((date) {
          return DropdownMenuItem<String>(
            value: date,
            child: Text(
              date,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedDate = value; // Ensure selected date is updated
          });
        },
      ),
    );
  }

  Widget _buildViewWeatherButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (selectedDate != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeatherScreen(selectedDate: selectedDate!),
            ),
          );
        }
      },
      child: Text(
        'View Weather',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 6,
        shadowColor: Colors.blue.withOpacity(0.4),
      ),
    );
  }
}
