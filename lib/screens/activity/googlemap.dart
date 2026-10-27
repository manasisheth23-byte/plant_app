import 'package:erpflutter/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const MapScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  LatLng? _center;
  final Set<Marker> _markers = {};
  bool _isMapLoading = true;
  String? _errorMessage;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initMap();
  }

  Future<void> _initMap() async {
    try {
      if (!mounted) return;

      setState(() {
        _isMapLoading = true;
        _errorMessage = null;
      });

      // Add a small delay to ensure proper initialization
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      setState(() {
        _center = LatLng(widget.latitude, widget.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId('selected_location'),
            position: LatLng(widget.latitude, widget.longitude),
            infoWindow: InfoWindow(title: widget.locationName),
          ),
        );
        _isMapReady = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error initializing map: $e';
        _isMapLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    try {
      if (!mounted) return;
      setState(() {
        _mapController = controller;
        _isMapLoading = false;
      });

      // Move camera to position after map is created
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _center!,
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error creating map: $e';
        _isMapLoading = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _mapController?.setMapStyle('[]');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.APPCOLOR,
        foregroundColor: Colors.white,
        title: const Text('Location Map',style: TextStyle(
          fontFamily: 'Roboto',
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (!_isMapReady) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _isMapLoading,
          child: SizedBox.expand(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center!,
                zoom: 15.0,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapType: MapType.normal,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                ),
              },
              onCameraMove: (position) {
                // Update camera position
              },
              onCameraIdle: () {
                // Camera movement completed
              },
            ),
          ),
        ),
        if (_isMapLoading)
          Container(
            color: Colors.white70,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initMap,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}