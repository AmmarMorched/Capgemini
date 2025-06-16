import 'package:capgemini/presentation/features/user/pages/settings.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domaine/Services/ModeManager.dart';
import '../../../../domaine/Services/UserService.dart';
import '../../../../domaine/entities/OBDData.dart';
import '../../../../domaine/entities/Vehicule.dart';
import '../../../shared/Menu_Drawer/bubble_drawer.dart';
import '../../user/pages/profile_screen.dart';
import '../widget/SlidingPanel.dart';
import '../../../shared/top_navbar.dart';
import '../../Connection/pages/WifiScanScreen.dart';
import '../../auth/pages/login_screen.dart';
import '../../../../theme/app_theme.dart';
import 'package:flutter/foundation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  // User details
  String? currentUserName;
  String? currentUserEmail;
  OBDData _currentData = OBDData(timestamp: DateTime.now());
  Vehicule? _vehicleInfo;
  String _status = 'Initializing...';
  bool _isLoading = false;
  final List<String> dtcs = [];
  List<String> pendingDtcs = [];
  final List<Map<String, dynamic>> gauges = [
    {
      'title': 'Engine Temp',
      'value': 85,
      'unit': '°C',
      'color': AppTheme.primaryColor,
    },
  ];
  ModeManager? _modeManager;

  @override
  void initState() {
    super.initState();
    //final modeManagerProvider = Provider.of<ModeManagerProvider>(context, listen: false);
    //_modeManager = modeManagerProvider.modeManager;
    if (_modeManager != null) {
      _setupListeners();
      _initializeConnection();
    }
  }

  void _setupListeners() {
    if (_modeManager == null) return;

    _modeManager!.statusStream.listen((status) {
      if (mounted) setState(() => _status = status);
    });
    _modeManager!.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          _currentData = data;
          pendingDtcs = data.pendingDtcs ?? [];

          // Handle VIN safely
          // if (data.vin?.isNotEmpty == true) {
          //   _updateVehiculeinfo(data.vin!);
          // }
        });
      }
    });
  }

  /// init connection with obd /////////////////
  Future<void> _initializeConnection() async {
    if (_modeManager?.isReconnecting == true) return;
    if (_modeManager?.isConnected == true) return;

    setState(() => _isLoading = true);
    try {
      await _modeManager?.initConnection();
      if (mounted && _modeManager?.isConnected == true) {
        await _modeManager?.getVehicleVIN();
        await _modeManager?.readDTCs();
        await _modeManager?.startMode1();
      }
    } catch (e) {
      debugPrint('Connection initialization failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  /// set up listeneers for OBD data and vehicle info////
  // void _setupListeners() {
  //   widget.modeManager.statusStream.listen((status) {
  //     if (mounted) setState(() => _status = status);
  //   });
  //   widget.modeManager.dataStream.listen((data) {
  //     if (mounted) {
  //       print("[DATA STREAM] New data received: $data");
  //       setState(() {
  //         _currentData = data;
  //         pendingDtcs = data.pendingDtcs ?? [];
  //
  //         // Handle VIN safely
  //         if (data.vin?.isNotEmpty == true) {
  //           _updateVehiculeinfo(data.vin!);
  //         }
  //       });
  //     }
  //   });
  // }

  /// Update vehicle information based on VIN
  // Future<void> _updateVehiculeinfo (String vin) async {
  //   try {
  //     if (_modeManager != null) {
  //       final carDetails = await _modeManager!.extractSelectedCarDetails(vin);
  //       setState(() {
  //         _vehicleInfo = Vehicule(
  //           make: carDetails['make'],
  //           model: carDetails['model'],
  //           year: carDetails['year'],
  //           vin: vin,
  //         );
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('Error fetching vehicle info: $e');
  //   }
  // }

  UserService sessionManager = UserService();
  // Fetch user details and update the UI
  void _fetchUserDetails() async {
    String? name = await sessionManager.getCurrentUserName();
    String? email = await sessionManager.getCurrentUserEmail();
    // Update the state to reflect the current user details
    setState(() {
      currentUserName = name;
      currentUserEmail = email;
    });
  }

  bool _isPanelVisible = false;

  void _togglePanel() {
    setState(() {
      _isPanelVisible = !_isPanelVisible;
    });
  }

  bool _isDrawerOpen = false;
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Builder(
          builder: (context) {
            return TopNavBar(
              // backgroundColor: theme.colorScheme.surface
              // foregroundColor: AppTheme.textColor,
              onMenuTap: () {
                setState(() {
                  _isDrawerOpen =! _isDrawerOpen;
                });
                Scaffold.of(context).openDrawer();
              },
              isConnected: _modeManager?.isConnected ?? false,
              isDrawerOpen: _isDrawerOpen,
            );
          },
        ),
      ),

      drawer: BubbleDrawer(

        onProfileTap:() {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          );
        },
        onConnectOBDTap: (){
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WifiScanScreen()),
          );
        },
        onSettingsTap: (){
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          );
        },
        onLogoutTap: () async{
          await sessionManager.logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) =>  LoginScreen()),
                (Route<dynamic> route) => false,
          );
        },
        onClose: (){
          setState(() =>_isDrawerOpen = false);
          Navigator.pop(context);
        },
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Add any main content here
                  ],
                ),
              ),
            ),
          ),
          const SlidingPanel(),
        ],
      ),
      //BottomNavBar(onItemSelected: (int ) {  },);
    );
  }
}