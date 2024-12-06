import 'package:flutter/material.dart';
import 'package:mining/miningApp/utils/constants.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import 'miningDataProvider.dart';

class Miningscreen extends StatefulWidget {
  final PersistentTabController controller;

  const Miningscreen({Key? key, required this.controller}) : super(key: key);

  @override
  State<Miningscreen> createState() => _MiningscreenState();
}

class _MiningscreenState extends State<Miningscreen> {
    @override
    Widget build(BuildContext context) {
      // Define the data for the Spline Range Area
      final List<SplineRangeAreaData> data = [
        SplineRangeAreaData('Mon', 200, 500),
        SplineRangeAreaData('Tue', 250, 450),
        SplineRangeAreaData('Wed', 300, 600),
        SplineRangeAreaData('Thu', 350, 550),
        SplineRangeAreaData('Fri', 400, 700),
        SplineRangeAreaData('Sat', 450, 800),
        SplineRangeAreaData('Sun', 300, 600),
      ];

      // Getting the screen height
      final screenHeight = MediaQuery.of(context).size.height;

      // Calculate the time remaining for the next reward
      String formatDuration(Duration duration) {
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
        String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
        return '${duration.inDays}d $twoDigitMinutes h $twoDigitSeconds s';
      }

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFffd735),
          leading: Padding(
            padding: const EdgeInsets.only(left: 10, top: 15),
            child: IconButton(
              icon: ImageIcon(
                AssetImage("assets/img_13.png"),
                size: 30,
                color: Colors.black,
              ),
              onPressed: () {
                widget.controller.jumpToTab(0);
              },
            ),
          ),
          elevation: 0,
        ),
        backgroundColor: const Color(0xFF07096d),
        body: Column(
          children: [
            // Top portion of the screen for the chart
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,  // Apply background color to the whole container
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),  // Make bottom-left corner circular
                  bottomRight: Radius.circular(20), // Make bottom-right corner circular
                ),
              ),
              child: Column(
                children: [
                  // Top portion with the chart
                  Container(
                    height: screenHeight * 0.20,  // Adjust height as needed
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: 1500,
                        interval: 300,
                      ),
                      legend: Legend(
                        isVisible: false,
                        position: LegendPosition.top,
                        overflowMode: LegendItemOverflowMode.wrap,
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries>[
                        SplineRangeAreaSeries<SplineRangeAreaData, String>(
                          name: '',
                          dataSource: data,
                          xValueMapper: (SplineRangeAreaData data, _) => data.day,
                          highValueMapper: (SplineRangeAreaData data, _) => data.high,
                          lowValueMapper: (SplineRangeAreaData data, _) => data.low,
                          color: const Color(0xFF010670).withOpacity(0.4),
                          borderColor: const Color(0xFF010670),
                          borderWidth: 2,
                          dataLabelSettings: const DataLabelSettings(isVisible: false),
                        ),
                      ],
                    ),
                  ),
                  // Bottom portion with the clickable image
                  Container(
                    height: 40,  // Adjust height as needed
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,  // Aligns content to the start (left side)
                      crossAxisAlignment: CrossAxisAlignment.center,  // Aligns vertically in the middle
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 14.0),  // Padding to move the image to the left
                          child: InkWell(
                            onTap: () {
                              // Handle button press here
                              print("Image button clicked!");
                              // Perform your action here
                            },
                            child: Image.asset(
                              'assets/img_15.png',  // Replace with your image asset path
                              height: 30,           // Adjust height of the image as needed
                              fit: BoxFit.contain,   // Adjust how the image fits in its container
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),




            // Middle portion with the background image and overlay text
            SizedBox(
              height: screenHeight * 0.30,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/middleImage.png',
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            // Displaying Next Reward text
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 17),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<MiningDataProvider>(
                      builder: (context, miningData, child) => Text(
                        'Next Reward in: ${formatDuration(miningData.nextRewardDuration)}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.yellow,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Consumer<MiningDataProvider>(
                      builder: (context, miningData, child) => Text(
                        'Hash Rate: ${miningData.hashRate.toStringAsFixed(2)} MH/s',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Consumer<MiningDataProvider>(
                      builder: (context, miningData, child) => Text(
                        'Blocks Mined: ${miningData.blocksMined}',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Consumer<MiningDataProvider>(
                      builder: (context, miningData, child) => Text(
                        'Mining Speed: ${miningData.miningSpeed.toStringAsFixed(2)} KH/s',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  // Data class for the spline range area chart
  class SplineRangeAreaData {
    final String day;
    final double low;
    final double high;

    SplineRangeAreaData(this.day, this.low, this.high);
  }