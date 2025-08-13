import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:brooski_app/core/utils/marker_generator.dart';
import 'package:brooski_app/features/home/widgets/price_marker_widget.dart';
import 'package:brooski_app/features/home/widgets/job_card.dart';
import 'package:brooski_app/core/models/filter_model.dart';
import 'package:brooski_app/features/jobs/models/job_model.dart';
import 'package:brooski_app/features/home/widgets/filter_bottom_sheet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// ---------------------------------------------------------------------------
/// Lightweight logger shim (no external dependency)
/// ---------------------------------------------------------------------------
class Logger {
  final String name;
  const Logger(this.name);
  void info(Object? message) => dev.log('$message', name: name, level: 800);
  void fine(Object? message) => dev.log('$message', name: name, level: 500);
  void warning(Object? message) => dev.log('$message', name: name, level: 900);
  void severe(Object? message, [Object? error, StackTrace? stackTrace]) =>
      dev.log('$message', name: name, error: error, stackTrace: stackTrace, level: 1000);
}

final _logger = Logger('WorkerHomeScreen');

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  // ----------- NEW: Safe default position & map style -----------
  static const LatLng _defaultPosition = LatLng(28.6139, 77.2090); // Delhi fallback
  // If you already have a map style file, you can delete this and use that.
  static const String _kDefaultMapStyleJson = '[]';

  loc.LocationData? _currentLocationData;
  GoogleMapController? _actionMapController;

  // UI State
  int _selectedJobIndex = 0;
  String? _selectedJobId;
  bool _isMapInteracting = false;
  bool _isLoading = true;
  bool _isMapView = true;

  // Timers and Data
  Timer? _jobRefreshTimer;
  final String _userName = "Raju"; // TODO: Fetch from user profile
  final double _walletBalance = 1250.50; // TODO: Fetch from user profile
  final List<Job> _availableJobs = [];
  List<Job> _filteredJobs = [];

  // Placeholder for current worker's skills
  final List<String> _workerSkills = ['Plumbing', 'Electrical', 'Painting'];

  FilterModel _currentFilters = FilterModel(
    priceRange: const RangeValues(100, 2000),
    distance: 10.0,
    showUrgentOnly: false,
    mySkillsOnly: false,
    timePosted: 'All',
    sortBy: 'Recommended',
    selectedSubCategories: {},
  );

  // Map and Controllers
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _jobMarkers = {};
  Set<Heatmap> _heatmaps = {};
  final PageController _pageController = PageController(viewportFraction: 0.85);

  // Action Map State
  bool _isJobAccepted = false;
  Job? _acceptedJob;
  final Set<Polyline> _polylines = {};
  final loc.Location _location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  final Set<Marker> _actionMapMarkers = {};
  String? _eta; // TODO: Calculate actual ETA from directions response

  // IMPORTANT: rotate this and move to secure config
  final String _googleApiKey = "AIzaSyDjNA_862a7cFDE8tAoOQSMf4JX3X3YVsg"; // TODO: Replace & secure

  // Simple cache for marker icons (perf)
  final Map<String, BitmapDescriptor> _markerCache = {};

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      final p = _pageController.hasClients ? _pageController.page : null;
      if (p == null) return;
      final nextPageIndex = p.round();
      if (_selectedJobIndex != nextPageIndex &&
          nextPageIndex >= 0 &&
          nextPageIndex < _filteredJobs.length) {
        setState(() {
          _selectedJobIndex = nextPageIndex;
          _selectedJobId = _filteredJobs[nextPageIndex].id;
        });
        _moveCameraToJob(nextPageIndex);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeJobs();
    });
  }

  @override
  void dispose() {
    _jobRefreshTimer?.cancel();
    _pageController.dispose();
    _mapController?.dispose();
    _actionMapController?.dispose();
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _startJobRefreshTimer() {
    _logger.info('Attempting to start job refresh timer...');
    _jobRefreshTimer?.cancel();
    _jobRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _logger.info('Tick! Firing auto-refresh.');
      _refreshJobs();
    });
    _logger.info('Job refresh timer started successfully.');
  }

  void _cancelJobRefreshTimer() {
    _logger.info('Cancelling job refresh timer.');
    _jobRefreshTimer?.cancel();
  }

  Future<void> _initializeJobs() async {
    if (!mounted) return;

    await _determinePosition();
    if (!mounted) return;

    _availableJobs.addAll(_generateMockJobs(15));
    _applyFilters(_currentFilters); // Apply initial filters
    _createHeatmap();
    if (_filteredJobs.isNotEmpty) {
      setState(() {
        _selectedJobId = _filteredJobs.first.id;
      });
    }
    await _createInitialJobMarkers();

    _startJobRefreshTimer();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshJobs() async {
    if (_isMapInteracting || !mounted) {
      if (_isMapInteracting) _logger.info('User is interacting with the map. Skipping refresh.');
      return;
    }
    _logger.info('Refreshing jobs quietly in the background...');
    // TODO: Implement actual API call to fetch new jobs
    final newJobs = _generateMockJobs(15);

    await _updateMarkersWithDiff(newJobs);

    if (mounted) {
      _availableJobs
        ..clear()
        ..addAll(newJobs);
      _applyFilters(_currentFilters);
    }

    _createHeatmap();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.warning('Location services are disabled.');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _logger.warning('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.severe('Location permissions are permanently denied, we cannot request permissions.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission permanently denied. Enable it in Settings.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      if (_mapController != null && _currentPosition != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition!, zoom: 14.0),
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.severe('Error determining position', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Couldn’t get location. Please enable GPS.')),
        );
      }
    }
  }

  List<Job> _generateMockJobs(int jobCount) {
    if (_currentPosition == null) return [];
    final random = Random();
    _logger.info('[MOCK API] Generating a new list of $jobCount jobs.');
    return List.generate(jobCount, (_) => _createRandomJob(random, _currentPosition!));
  }

  Job _createRandomJob(Random random, LatLng currentPosition) {
    final latOffset = (random.nextDouble() - 0.5) * 0.1; // ~5km radius
    final lngOffset = (random.nextDouble() - 0.5) * 0.1;
    final jobLocation = LatLng(currentPosition.latitude + latOffset, currentPosition.longitude + lngOffset);
    final distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          jobLocation.latitude,
          jobLocation.longitude,
        ) /
        1000;

    final posterNames = ['Riya Sharma', 'Amit Patel', 'Priya Singh', 'Rohan Gupta'];
    final jobTitles = ['Urgent AC Repair', 'Leaky Kitchen Pipe', 'Fix Faulty Wiring', 'Deep House Cleaning', 'Garden Overhaul', 'Custom Bookshelf'];
    final categories = ['Electrical', 'Plumbing', 'Electrical', 'Cleaning', 'Gardening', 'Carpentry'];
    final posterIndex = random.nextInt(posterNames.length);

    return Job(
      id: 'job_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}',
      title: jobTitles[random.nextInt(jobTitles.length)],
      category: categories[random.nextInt(categories.length)],
      description: 'This is a detailed description for a randomly generated job. It requires professional skills and tools.',
      pay: 500 + random.nextInt(2500),
      urgency: ['Now', 'Today', 'Flexible'][random.nextInt(3)],
      location: jobLocation,
      address: '123, Tech Park, Silicon Valley',
      postedAt: DateTime.now().subtract(Duration(minutes: random.nextInt(120))),
      poster: Poster(
        name: posterNames[posterIndex],
        imageUrl: 'https://i.pravatar.cc/150?u=${posterNames[posterIndex]}',
        isVerified: random.nextBool(),
        rating: 3.5 + random.nextDouble() * 1.5,
        phoneNumber: '1234567890',
      ),
      mediaUrls: random.nextBool() ? ['https://via.placeholder.com/150'] : [],
      distance: distance,
    );
  }

  Future<BitmapDescriptor> _getMarkerIcon(Job job) async {
    final key = '${job.category}_${job.urgency == "Now"}_${(job.pay / 200).floor()}';
    if (_markerCache.containsKey(key)) return _markerCache[key]!;
    final widgets = [
      PriceMarkerWidget(
        price: job.pay.toString(),
        category: job.category,
        isUrgent: job.urgency == 'Now',
      ),
    ];
    final bmp = (await MarkerGenerator(context, widgets).generate()).first;
    _markerCache[key] = bmp;
    return bmp;
  }

  Future<void> _createInitialJobMarkers() async {
    if (!mounted || _availableJobs.isEmpty) return;

    try {
      final bitmaps = await Future.wait(_availableJobs.map(_getMarkerIcon));
      if (!mounted) return;

      final newMarkers = <Marker>{};
      for (int i = 0; i < _availableJobs.length; i++) {
        final job = _availableJobs[i];
        newMarkers.add(
          Marker(
            markerId: MarkerId(job.id),
            position: job.location,
            icon: bitmaps[i],
            anchor: const Offset(0.5, 0.5),
            onTap: () => _onMarkerTapped(job),
          ),
        );
      }
      setState(() {
        _jobMarkers
          ..clear()
          ..addAll(newMarkers);
      });
    } catch (e, stackTrace) {
      _logger.severe('Error generating markers', e, stackTrace);
    }
  }

  Future<void> _updateMarkersWithDiff(List<Job> newJobs) async {
    if (!mounted) return;

    final oldJobIds = _jobMarkers.map((m) => m.markerId.value).toSet();
    final newJobIds = newJobs.map((j) => j.id).toSet();

    final jobsToAdd = newJobs.where((j) => !oldJobIds.contains(j.id)).toList();
    final jobIdsToRemove = oldJobIds.difference(newJobIds);

    List<BitmapDescriptor> newMarkerBitmaps = [];
    if (jobsToAdd.isNotEmpty) {
      try {
        newMarkerBitmaps = await Future.wait(jobsToAdd.map(_getMarkerIcon));
      } catch (e, st) {
        _logger.severe('Error generating new markers', e, st);
        newMarkerBitmaps = [];
      }
    }

    if (!mounted) return;
    setState(() {
      _jobMarkers.removeWhere((m) => jobIdsToRemove.contains(m.markerId.value));
      if (jobsToAdd.isNotEmpty && newMarkerBitmaps.length == jobsToAdd.length) {
        for (int i = 0; i < jobsToAdd.length; i++) {
          final job = jobsToAdd[i];
          _jobMarkers.add(
            Marker(
              markerId: MarkerId(job.id),
              position: job.location,
              icon: newMarkerBitmaps[i],
              anchor: const Offset(0.5, 0.5),
              onTap: () => _onMarkerTapped(job),
            ),
          );
        }
      }
    });
  }

  void _createHeatmap() {
    if (!mounted) return;

    if (_filteredJobs.isEmpty) {
      setState(() => _heatmaps = {});
      return;
    }

    const double urgencyBonus = 1.5;
    const double highPayBonus = 2.0;
    const double highPayThreshold = 1500;

    final List<WeightedLatLng> heatmapData = _filteredJobs.map((job) {
      double weight = 1.0;
      if (job.urgency == 'Now') weight += urgencyBonus;
      if (job.pay > highPayThreshold) weight += highPayBonus;
      return WeightedLatLng(job.location, weight: weight);
    }).toList();

    final heatmap = Heatmap(
      heatmapId: const HeatmapId('job_heatmap'),
      data: heatmapData,
      radius: HeatmapRadius.fromPixels(40),
      gradient: HeatmapGradient([
        HeatmapGradientColor(const Color.fromRGBO(0, 0, 255, 0.2), 0.2),
        HeatmapGradientColor(Colors.orange, 0.5),
        HeatmapGradientColor(Colors.red, 0.9),
      ]),
      opacity: 0.8,
    );

    setState(() {
      _heatmaps = {heatmap};
    });
  }

  void _onMarkerTapped(Job job) {
    final jobIndex = _filteredJobs.indexWhere((j) => j.id == job.id);
    if (jobIndex != -1) {
      _pageController.animateToPage(
        jobIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _moveCameraToJob(int jobIndex) {
    if (jobIndex < 0 || jobIndex >= _filteredJobs.length) return;
    final job = _filteredJobs[jobIndex];
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: job.location, zoom: 15.0),
      ),
    );
  }

  void _centerOnUserLocation() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition!, zoom: 14.0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.fine('Building WorkerHomeScreen. _isJobAccepted: $_isJobAccepted');
    return Scaffold(
      appBar: _isJobAccepted ? _buildActionMapAppBar() : _buildDiscoveryAppBar(),
      body: _isJobAccepted ? _buildActionMapView() : (_isMapView ? _buildMapView() : _buildJobListView()),
      floatingActionButton: !_isJobAccepted ? _buildDiscoveryFabs() : null,
    );
  }

  AppBar _buildActionMapAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        _acceptedJob?.title ?? 'En Route',
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 2,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton(
            onPressed: _showCancelConfirmationDialog,
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.red[700], fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
        )
      ],
    );
  }

  AppBar _buildDiscoveryAppBar() {
    return AppBar(
      title: Text('Welcome, $_userName!', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Chip(
            avatar: const Icon(Icons.account_balance_wallet_outlined, size: 18, color: Colors.green),
            label: Text(
              '\$${_walletBalance.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            backgroundColor: Colors.green.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        IconButton(
          icon: Icon(_isMapView ? Icons.list_alt_outlined : Icons.map_outlined),
          tooltip: _isMapView ? 'List View' : 'Map View',
          onPressed: () {
            setState(() {
              _isMapView = !_isMapView;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            _logger.info('Notifications button pressed.'); // TODO: Navigate to notifications screen
          },
        ),
      ],
    );
  }

  Widget _buildDiscoveryFabs() {
    final filterFab = FloatingActionButton(
      heroTag: 'filter_fab',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            builder: (_, controller) => FilterBottomSheet(
              initialFilters: _currentFilters,
              onApply: (newFilters) {
                _applyFilters(newFilters);
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
      backgroundColor: const Color(0xFF2ECC71),
      child: const Icon(Icons.filter_list, color: Colors.white, size: 28),
    );

    if (!_isMapView) {
      return filterFab;
    }

    // In Map view, show both filter and center buttons
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'center_map_fab',
          mini: true,
          onPressed: _centerOnUserLocation,
          backgroundColor: Colors.white,
          child: const Icon(Icons.my_location, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        filterFab,
      ],
    );
  }

  Widget _buildJobListView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredJobs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshJobs,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Icon(Icons.work_off_outlined, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No jobs available right now.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Pull down to refresh.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _filteredJobs.length,
        itemBuilder: (context, index) {
          final job = _filteredJobs[index];
          return JobCard(
            job: job,
            isSelected: _selectedJobId == job.id,
            onAccept: _showAcceptJobDialog,
          );
        },
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        _currentPosition == null
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition ?? _defaultPosition,
                  zoom: 12,
                ),
                style: _kDefaultMapStyleJson, // ← replaces deprecated setMapStyle
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onCameraMoveStarted: () {
                  setState(() {
                    _isMapInteracting = true;
                  });
                },
                onCameraIdle: () {
                  setState(() {
                    _isMapInteracting = false;
                  });
                },
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  if (_currentPosition != null) {
                    _centerOnUserLocation();
                  }
                },
                markers: _jobMarkers,
                heatmaps: _heatmaps,
              ),
        _buildJobCardSlider(),
      ],
    );
  }

  Widget _buildJobCardSlider() {
    return Positioned(
      bottom: 24.0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 220,
        child: PageView.builder(
          controller: _pageController,
          itemCount: _filteredJobs.length,
          itemBuilder: (context, index) {
            return JobCard(
              job: _filteredJobs[index],
              isSelected: _selectedJobIndex == index,
              onAccept: _showAcceptJobDialog,
            );
          },
        ),
      ),
    );
  }

  void _showAcceptJobDialog(Job job) {
    _logger.info('Showing accept job dialog for "${job.title}".');
    _cancelJobRefreshTimer(); // Pause background activity

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Confirm Job Acceptance', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
              children: <TextSpan>[
                const TextSpan(text: 'Do you want to accept the job '),
                TextSpan(text: '"${job.title}"', style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: ' from '),
                TextSpan(text: job.poster.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[600])),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Confirm',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    ).then((accepted) {
      if (accepted == true) {
        _acceptJob(job);
      } else {
        _logger.info('Job acceptance cancelled or dialog dismissed. Restarting timer.');
        _startJobRefreshTimer();
      }
    });
  }

  void _acceptJob(Job job) {
    _logger.info('[ACCEPT JOB] Starting job acceptance for "${job.title}".');
    if (!mounted) return;

    setState(() {
      _isJobAccepted = true;
      _acceptedJob = job;
      _jobMarkers.clear();
      _heatmaps.clear();
      _polylines.clear();
    });

    _createActionMapMarkers();
    _createRoute();
    _startLiveLocationUpdates();
  }

  Widget _buildActionMapView() {
    _logger.fine('Building Action Map View.');
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition ?? _defaultPosition,
            zoom: 12,
          ),
          style: _kDefaultMapStyleJson, // ← replaces deprecated setMapStyle
          onMapCreated: (GoogleMapController controller) {
            _actionMapController = controller;
            // Fit bounds handled after route polyline is set
            Future.delayed(const Duration(milliseconds: 400), _fitActionBounds);
          },
          markers: _actionMapMarkers,
          polylines: _polylines,
          myLocationButtonEnabled: false,
          myLocationEnabled: false, // Using custom marker
          zoomControlsEnabled: false,
        ),
        _buildActionCard(),
      ],
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    final ok = await launchUrl(url);
    if (!ok) {
      _logger.warning('Could not launch $urlString');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $urlString. Please check your device settings.')),
        );
      }
    }
  }

  Widget _buildActionCard() {
    if (_acceptedJob == null) return const SizedBox.shrink();

    final poster = _acceptedJob!.poster;
    const actionColor = Color(0xFF2ECC71);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Poster Info & ETA
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(poster.imageUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poster.name,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _acceptedJob!.title,
                          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ETA', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12)),
                      Text(
                        _eta ?? '- mins',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: actionColor),
                      ),
                    ],
                  )
                ],
              ),
              const Divider(height: 24),
              // Row 2: Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(Icons.call_outlined, 'Call', () => _launchUrl('tel:${poster.phoneNumber}')),
                  _buildActionButton(Icons.chat_bubble_outline, 'Chat', () => _launchUrl('sms:${poster.phoneNumber}')),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('I\'ve Arrived'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Arrival notification sent (simulation).')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Row 3: Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancel Job'),
                  onPressed: _showCancelConfirmationDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    side: BorderSide(color: Colors.red[700]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    const actionColor = Color(0xFF2ECC71);
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: actionColor,
        side: const BorderSide(color: actionColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Cancel Job?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: Text(
            'Cancelling a job after acceptance may negatively affect your rating and eligibility for rewards. Are you sure you want to proceed?',
            style: GoogleFonts.lato(fontSize: 15),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Go Back', style: GoogleFonts.montserrat()),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Confirm Cancellation', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _resetToDiscovery();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetToDiscovery() {
    _logger.info('[ACTION MAP] Job cancelled. Resetting to discovery mode.');
    _locationSubscription?.cancel();
    if (mounted) {
      setState(() {
        _isJobAccepted = false;
        _acceptedJob = null;
        _polylines.clear();
        _eta = null;
        _actionMapMarkers.clear();
      });
    }
    _refreshJobs();
    _startJobRefreshTimer();
  }

  void _createActionMapMarkers() {
    if (_currentPosition == null || _acceptedJob == null) return;

    final workerMarker = Marker(
      markerId: const MarkerId('worker_location'),
      position: _currentPosition!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      rotation: _currentLocationData?.heading ?? 0.0,
      anchor: const Offset(0.5, 0.5),
      flat: true,
      zIndexInt: 2, // updated
    );

    final jobMarker = Marker(
      markerId: const MarkerId('job_destination'),
      position: _acceptedJob!.location,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: _acceptedJob!.title, snippet: _acceptedJob!.address),
      zIndexInt: 1,
    );

    if (mounted) {
      setState(() {
        _actionMapMarkers
          ..clear()
          ..add(workerMarker)
          ..add(jobMarker);
      });
    }
  }

  Future<void> _createRoute() async {
    if (_currentPosition == null || _acceptedJob == null) {
      _logger.warning('[ROUTE] Missing current position or accepted job. Cannot create route.');
      return;
    }

    if (_googleApiKey.contains('YOUR_GOOGLE_API_KEY')) {
      _logger.severe('[ROUTE] ERROR: Google API Key is still a placeholder. Please replace it in the code.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Map feature is not configured. Please contact support.'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${_acceptedJob!.location.latitude},${_acceptedJob!.location.longitude}&mode=driving&key=$_googleApiKey';
    _logger.info('[ROUTE] Requesting route from URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final routes = jsonResponse['routes'] as List?;
        if (routes == null || routes.isEmpty) {
          _logger.warning('[ROUTE] Directions API: No routes found. Message: ${jsonResponse['status']} ${jsonResponse['error_message'] ?? ''}');
          return;
        }

        final first = routes.first as Map;
        final overview = (first['overview_polyline'] ?? {}) as Map;
        final polylinePoints = overview['points'] as String?;
        final legs = first['legs'] as List?;
        final leg = (legs != null && legs.isNotEmpty) ? legs.first as Map : null;
        final durationText = (leg?['duration'] as Map?)?['text'] as String?;

        if (polylinePoints == null) {
          _logger.warning('[ROUTE] No overview polyline points in response.');
          return;
        }

        final decodedPoints = PolylinePoints().decodePolyline(polylinePoints);
        final List<LatLng> polylineCoordinates = [
          for (final p in decodedPoints) LatLng(p.latitude, p.longitude)
        ];

        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue.withValues(alpha: 0.8),
          points: polylineCoordinates,
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        );

        if (mounted) {
          setState(() {
            _polylines
              ..clear()
              ..add(polyline);
            _eta = durationText;
          });
          _fitActionBounds();
        }
        _logger.info('[ROUTE] Route created successfully with ETA: ${durationText ?? '-'}');
      } else {
        _logger.warning('[ROUTE] Directions API request failed with status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.severe('[ROUTE] Exception caught while creating route', e, stackTrace);
    }
  }

  void _fitActionBounds() {
    if (_currentPosition == null || _acceptedJob == null || _actionMapController == null) return;
    final southwest = LatLng(
      min(_currentPosition!.latitude, _acceptedJob!.location.latitude),
      min(_currentPosition!.longitude, _acceptedJob!.location.longitude),
    );
    final northeast = LatLng(
      max(_currentPosition!.latitude, _acceptedJob!.location.latitude),
      max(_currentPosition!.longitude, _acceptedJob!.location.longitude),
    );
    _actionMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southwest, northeast: northeast),
        100.0,
      ),
    );
  }

  void _startLiveLocationUpdates() {
    _logger.info('[LOCATION] Starting live location updates for Action Map.');
    _locationSubscription?.cancel();
    _location.changeSettings(accuracy: loc.LocationAccuracy.high, interval: 2000, distanceFilter: 10);
    _locationSubscription = _location.onLocationChanged.listen((loc.LocationData newLocation) {
      if (mounted && _isJobAccepted) {
        _currentLocationData = newLocation;
        if (newLocation.latitude != null && newLocation.longitude != null) {
          _currentPosition = LatLng(newLocation.latitude!, newLocation.longitude!);
          _updateWorkerMarkerAndCamera();
        }
      }
    });
  }

  void _updateWorkerMarkerAndCamera() {
    if (_currentPosition == null || _actionMapController == null) return;

    final workerMarker = Marker(
      markerId: const MarkerId('worker_location'),
      position: _currentPosition!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      rotation: _currentLocationData?.heading ?? 0.0,
      anchor: const Offset(0.5, 0.5),
      flat: true,
      zIndexInt: 2,
    );

    if (mounted) {
      setState(() {
        _actionMapMarkers.removeWhere((m) => m.markerId.value == 'worker_location');
        _actionMapMarkers.add(workerMarker);
      });
    }

    _actionMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition!,
          zoom: 17.5,
          tilt: 45.0,
          bearing: _currentLocationData?.heading ?? 0.0,
        ),
      ),
    );
  }

  void _applyFilters(FilterModel newFilters) {
    setState(() {
      _currentFilters = newFilters;
      List<Job> tempFilteredJobs = _availableJobs.where((job) {
        if (job.pay < newFilters.priceRange.start || job.pay > newFilters.priceRange.end) {
          return false;
        }

        if (job.distance != null && job.distance! > newFilters.distance) {
          return false;
        }

        if (newFilters.showUrgentOnly && job.urgency.toLowerCase() != 'now') {
          return false;
        }

        if (newFilters.mySkillsOnly && !_workerSkills.contains(job.category)) {
          return false;
        }

        if (!newFilters.mySkillsOnly &&
            newFilters.selectedSubCategories.isNotEmpty &&
            !newFilters.selectedSubCategories.contains(job.category)) {
          return false;
        }

        final now = DateTime.now();
        if (newFilters.timePosted == 'Last 1 hour' && now.difference(job.postedAt).inHours >= 1) {
          return false;
        }
        if (newFilters.timePosted == 'Today' &&
            (now.day != job.postedAt.day || now.month != job.postedAt.month || now.year != job.postedAt.year)) {
          return false;
        }

        return true;
      }).toList();

      switch (newFilters.sortBy) {
        case 'Price (High → Low)':
          tempFilteredJobs.sort((a, b) => b.pay.compareTo(a.pay));
          break;
        case 'Distance (Near → Far)':
          tempFilteredJobs.sort((a, b) => (a.distance ?? double.infinity).compareTo(b.distance ?? double.infinity));
          break;
        case 'Newest':
          tempFilteredJobs.sort((a, b) => b.postedAt.compareTo(a.postedAt));
          break;
        case 'Recommended':
        default:
          // TODO: Implement a real recommendation algorithm.
          break;
      }

      _filteredJobs = tempFilteredJobs;

      // After filtering and sorting, update markers and selected job
      _updateMarkersWithDiff(_filteredJobs);
      if (_filteredJobs.isNotEmpty) {
        _pageController.jumpToPage(0);
      }
    });
  }
}
