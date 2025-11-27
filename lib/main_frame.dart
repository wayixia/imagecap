
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';





class MainFrame extends StatefulWidget {
  const MainFrame({super.key});

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.none;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = -1.0;
  String _selectedTitle = 'ColorPicker';
  late final List<NavigationRailDestination> _destinations;

  @override
  void initState() {
    super.initState();
    _destinations = generateDestination();
  }

  List<NavigationRailDestination> generateDestination() {
    return <NavigationRailDestination>[ 
      NavigationRailDestination( 
        // ignore: deprecated_member_use 
        icon: SvgPicture.asset( 'assets/images/svg/colorpicker.svg', width:26, height:26, color: Colors.black,),
        // ignore: deprecated_member_use
        selectedIcon: SvgPicture.asset( 'assets/images/svg/colorpicker.svg', width:26, height:26, color: Colors.grey[800],),
        label: const Text('ColorPicker'),
      ),
      NavigationRailDestination(
        icon: SvgPicture.asset( 'assets/images/svg/capture.svg', width:26, height:26),
        selectedIcon: SvgPicture.asset( 'assets/images/svg/capture.svg', width:26, height:26, color: Colors.grey[800],),
        label: const Text('ScreenCaptrue'),
      ),
      const NavigationRailDestination(
        icon: Badge(label: Text('4'), child: Icon(Icons.settings_outlined)),
        selectedIcon: Badge(label: Text('4'), child: Icon(Icons.settings)),
        label: Text('Settings'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            NavigationRail(
              minWidth: 60,
              
              selectedIndex: _selectedIndex,
              groupAlignment: groupAlignment,
              onDestinationSelected: (int index) {
                Text t = _destinations[index].label as Text;
                setState(() {
                  _selectedIndex = index;
                  _selectedTitle = t.data??'';
                });
              },
              labelType: labelType,
              leading: showLeading
                  ? FloatingActionButton(
                      elevation: 0,
                      onPressed: () {
                        // Add your onPressed code here!
                      },
                      child: const Icon(Icons.add),
                    )
                  : const SizedBox(),
              trailing: showTrailing
                  ? IconButton(
                      onPressed: () {
                        // Add your onPressed code here!
                      },
                      icon: const Icon(Icons.more_horiz_rounded),
                    )
                  : const SizedBox(),
              destinations: _destinations,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // This is the main content.
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration( 
                      color: Colors.white,
                      border: Border( 
                        bottom: BorderSide( 
                          color: Color.fromARGB(0xff, 0xEE, 0xEE, 0xEE), // 底部边框颜色 
                          width: 1.0, // 底部边框宽度
                        ),),),
                    height: 50, 
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    
                    child:  Row(children: [
                       Text('  > $_selectedTitle', 
                        style: 
                          TextStyle(color: Colors.black87, 
                            fontSize: 15, 
                            fontWeight: FontWeight.w500
                          ),
                      ),
                      Spacer(),
                      SizedBox( 
                        width: 70,
                        height: 36,
                        child: FloatingActionButton( 
                          //onPressed: _incrementCounter, 
                          tooltip: 'Increment', 
                          onPressed: () { 
                            // Add your onPressed code here!
                            if( _selectedIndex == 0 ) {
                              debugPrint('ColorPicker Add');

                            } else if( _selectedIndex == 1 ) {
                              debugPrint('ScreenCaptrue Add');
                              doCaptureScreen();
                            } else if( _selectedIndex == 2 ) {
                              debugPrint('Settings Add');
                            }
                          },
                          mini: true, 
                          elevation: 1, 
                          backgroundColor: Colors.amber, 
                          hoverElevation: 1, 
                          // hoverColor: Color.fromARGB(0xFF, 0xF1, 0xF1, 0xF1), 
                          focusElevation: 1, 
                          // splashColor: Colors.transparent,
                          highlightElevation: 1, // 将阴影高度设置为0
                          child: const Icon(Icons.add),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],)
                     
                  ),
                  Expanded(child: Container(color: Colors.white, width: double.infinity,)),
                 
                  // const SizedBox(height: 10),
                  // SegmentedButton<NavigationRailLabelType>(
                  //   segments: const <ButtonSegment<NavigationRailLabelType>>[
                  //     ButtonSegment<NavigationRailLabelType>(
                  //       value: NavigationRailLabelType.none,
                  //       label: Text('None'),
                  //     ),
                  //     ButtonSegment<NavigationRailLabelType>(
                  //       value: NavigationRailLabelType.selected,
                  //       label: Text('Selected'),
                  //     ),
                  //     ButtonSegment<NavigationRailLabelType>(
                  //       value: NavigationRailLabelType.all,
                  //       label: Text('All'),
                  //     ),
                  //   ],
                  //   selected: <NavigationRailLabelType>{labelType},
                  //   onSelectionChanged: (Set<NavigationRailLabelType> newSelection) {
                  //     setState(() {
                  //       labelType = newSelection.first;
                  //     });
                  //   },
                  // ),
                  // const SizedBox(height: 20),
                  // Text('Group alignment: $groupAlignment'),
                  // const SizedBox(height: 10),
                  // SegmentedButton<double>(
                  //   segments: const <ButtonSegment<double>>[
                  //     ButtonSegment<double>(value: -1.0, label: Text('Top')),
                  //     ButtonSegment<double>(value: 0.0, label: Text('Center')),
                  //     ButtonSegment<double>(value: 1.0, label: Text('Bottom')),
                  //   ],
                  //   selected: <double>{groupAlignment},
                  //   onSelectionChanged: (Set<double> newSelection) {
                  //     setState(() {
                  //       groupAlignment = newSelection.first;
                  //     });
                  //   },
                  // ),
                  // const SizedBox(height: 20),
                  // SwitchListTile(
                  //   title: Text(showLeading ? 'Hide Leading' : 'Show Leading'),
                  //   value: showLeading,
                  //   onChanged: (bool value) {
                  //     setState(() {
                  //       showLeading = value;
                  //     });
                  //   },
                  // ),
                  // SwitchListTile(
                  //   title: Text(showTrailing ? 'Hide Trailing' : 'Show Trailing'),
                  //   value: showTrailing,
                  //   onChanged: (bool value) {
                  //     setState(() {
                  //       showTrailing = value;
                  //     });
                  //   },
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> doCaptureScreen() async {
    // Create a new window

    final controller = await WindowController.create(
      WindowConfiguration(
        hiddenAtLaunch: true,
        arguments: '--name=capturewnd',
        isPanel:false 
      ),
    ); 
    
    // Show the window (if hidden at launch) 
    await controller.show();
  }
}