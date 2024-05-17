import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'userData.dart';


class RedOffers extends StatefulWidget {
  @override
  _RedOffersState createState() => _RedOffersState();
}

class _RedOffersState extends State<RedOffers> {
  List<Map<String, dynamic>> offerData = [];

  @override
  void initState() {
    super.initState();
    _loadOfferData();
  }

  Future<void> _loadOfferData() async {
    try {
      final String response = await rootBundle.loadString('data/offers.json');
      final data = jsonDecode(response);
      if (data is Map<String, dynamic> && data.containsKey('services')) {
        final serviceList = data['services'] as List<dynamic>;
        setState(() {
          offerData = serviceList.cast<Map<String, dynamic>>();
        });
      } else {
        print('Invalid JSON data structure');
        _showLoadingError();
      }
    } catch (e) {
      print('Failed to load offer data: $e');
      _showLoadingError();
    }
  }

  void _showLoadingError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to load requests data.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _reloadOffers() {
    setState(() {
      _loadOfferData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Utils.buildInternalPageContainer(
      LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  'Current Offers',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              Expanded(
                child: offerData.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: offerData.length,
                        itemBuilder: (context, index) {
                          var offer = offerData[index];
                          String imagePath = Utils.getImagePath(offer);
                          String detail = "${offer['buddyType']} - ${offer['title']}";
                          return GestureDetector(
                            onTap: () {
                              _showOfferCardDialog(context, offer);
                            },
                            child: Container(
                              height: constraints.maxHeight * 0.15,
                              padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05),
                              child: Card(
                                child: Stack(
                                  children: [
                                    ListTile(
                                      title: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          detail,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${offer["instructor"]} - ${offer["location"]}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 16,
                                      bottom: 8,
                                      child: Text(
                                        '\$${offer["price"]}',
                                        style: TextStyle(
                                          color: Color(0xFFFF6868),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 16,
                                      bottom: 8,
                                      child: Image.asset(
                                        imagePath,
                                        fit: BoxFit.cover,
                                        height: constraints.maxHeight * 0.15 * 0.7,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _reloadOffers,
                tooltip: "Refresh Offers",
              ),
            ],
          );
        },
      ),
    );
  }

  void _showOfferCardDialog(BuildContext context, Map<String, dynamic> offer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.deepOrange[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            child: OfferCard(offer: offer),
          ),
        );
      },
    );
  }
}

class OfferCard extends StatelessWidget {
  final Map<String, dynamic>? offer;

  OfferCard({this.offer});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Header Section
                Container(
                  height: MediaQuery.of(context).size.height * 0.2 * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        offer?['title'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'By ${offer?['instructor'] ?? ''}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Section
                Container(
                  height: MediaQuery.of(context).size.height * 0.75 * 0.7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left-aligned Fields
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildField('Type of Service', offer?['typeOfService'] ?? '-', 'start'),
                          if (offer?['buddyType'] == 'Scholar Buddy')
                            _buildField('Subject Taught', offer?['subjectTaught'] ?? '-', 'start'),
                          if (offer?['buddyType'] == 'Scholar Buddy')
                            _buildField('Education Level', offer?['educationLevel'] ?? '-', 'start'),
                          if (offer?['buddyType'] == 'Driving Buddy')
                            _buildField('Auto Type', offer?['autoType'] ?? '-', 'start'),
                          if (offer?['buddyType'] == 'Driving Buddy')
                            _buildField('Vehicle Make', offer?['vehicleMake'] ?? '-', 'start'),
                          if (offer?['buddyType'] == 'Driving Buddy')
                            _buildField('Vehicle Type', offer?['vehicleType'] ?? '-', 'start'),
                          _buildField('Skill Level', offer?['skillLevel'] ?? '-', 'start'),
                        ],
                      ),

                      // Right-aligned Fields
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildField('Buddy Type', offer?['buddyType'] ?? '-', 'end'),
                          _buildField('Location', offer?['location'] ?? '-', 'end'),
                          _buildField('Availability', offer?['availability'] ?? '-', 'end'),
                          _buildField('Instructor', offer?['instructor'] ?? '-', 'end'),
                          _buildField('Experience', offer?['instructorExperience'] ?? '-', 'end'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Footer Section
                Container(
                  height: MediaQuery.of(context).size.height * 0.1 * 0.7, // 10% of the screen height
                  child: Center(
                    child: CupertinoButton.filled(
                      child: Text('Chat'),
                      onPressed: () {
                        // No action for now
                      },
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, String alignment) {
    // Determine alignment based on the `alignment` argument
    CrossAxisAlignment crossAxisAlignment;
    if (alignment == 'start') {
      crossAxisAlignment = CrossAxisAlignment.start;
    } else if (alignment == 'end') {
      crossAxisAlignment = CrossAxisAlignment.end;
    } else {
      crossAxisAlignment = CrossAxisAlignment.center;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}

class BlueMyOffers extends StatefulWidget {
  @override
  _BlueMyOffersState createState() => _BlueMyOffersState();
}

class _BlueMyOffersState extends State<BlueMyOffers> {
  Future<List<Map<String, dynamic>>> readOffers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/acolyte/myoffers.json');
      final contents = await file.readAsString();
      final offers = json.decode(contents) as List;
      return offers.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  void _showEditOfferDialog(BuildContext context, Map<String, dynamic> offer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.green[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            child: OfferForm(
              isEditing: true,
              offer: offer,
              onSave: _reloadOffers, // Pass the reload function to the form
            ),
          ),
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  return Utils.buildInternalPageContainer(
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'My Offers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: readOffers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading offers'));
              } else {
                final offers = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    final imagePath = Utils.getImagePath(offer);
                    final detail = "${offer['buddyType']} - ${offer['title']}";
                    return GestureDetector(
                      onTap: () {
                        _showEditOfferDialog(context, offer);
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                        child: Card(
                          child: Stack(
                            children: [
                              ListTile(
                                title: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    detail,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                subtitle: Text(
                                  '${offer["location"]} - ${offer["availability"]}\n${offer["instructor"]}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 8,
                                child: Text(
                                  '${offer["price"]}\$ / hr',
                                  style: TextStyle(
                                    color: Color(0xFF356DFF),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 16,
                                bottom: 8,
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  height: MediaQuery.of(context).size.height * 0.15 * 0.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        Utils.buildAddButton(context, Colors.blueAccent, onTap: _showAddOfferDialog),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _reloadOffers,
          tooltip: "Refresh Offers",
        ),
      ],
    ),
  );
}

  void _showAddOfferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.green[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            child: OfferForm(
              onSave: _reloadOffers, // Pass the reload function to the form
            ),
          ),
        );
      },
    );
  }

  void _reloadOffers() {
    setState(() {
      // This will trigger the FutureBuilder to rebuild and fetch the offers again
    });
  }
}

class OfferForm extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? offer;
  final VoidCallback? onSave; // Add an optional callback for saving

  OfferForm({this.isEditing = false, this.offer, this.onSave});

  @override
  _OfferFormState createState() => _OfferFormState();
}

class _OfferFormState extends State<OfferForm> {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for common fields
  TextEditingController titleController = TextEditingController(); // title
  TextEditingController locationController = TextEditingController(); // location
  TextEditingController priceController = TextEditingController(); // price
  TextEditingController whenController = TextEditingController(); // availability

  // Text editing controllers for Driving Lessons
  TextEditingController autoTypeController = TextEditingController(); // autoType
  TextEditingController vehicleMakeController = TextEditingController(); // vehicleMake
  TextEditingController vehicleTypeController = TextEditingController(); // vehicleType
  TextEditingController instructorExperienceController = TextEditingController(); // instructorExperience

  // Text editing controllers for Classes
  TextEditingController educationLevelController = TextEditingController(); // educationLevel
  TextEditingController skillLevelController = TextEditingController(); // skillLevel
  TextEditingController subjectTeachedController = TextEditingController(); // Subject Taught

  // Dropdown initial values and lists
  String selectedlocation = '';
  String selectedService = '';
  String selectedVehicleType = '';
  String selectedEducationLevel = '';
  String selectedSkillLevel = '';
  String selectedInstructorExperience = '';
  List<String> locations = ['-', 'Online', 'Montreal', 'Quebec', 'Laval', 'Longueuil'];
  List<String> services = [
    '-',
    'Driving Lessons',
    'Math Classes',
    'Biology Classes',
    'Physics Classes',
    'STEM Classes',
    'Languages Classes',
    'Computer Science Classes'
  ];
  List<String> vehicleTypes = ['-', 'SUV', 'Pickup', 'Sedan', 'Sports', 'Luxury'];
  List<String> educationLevels = ['-', 'Preschool', 'HighSchool', 'College', 'University'];
  List<String> skillLevels = ['-', 'Beginner', 'Intermediate', 'Advanced', 'Expert'];
  List<String> instructorExperiences = ['-', '1 year', '2-5 years', '5-7 years', '8-10 years', '10+ years'];
  bool isFormModified = false;


  // Methods for handling the acolyte/myoffers.json file
  Future<List<Map<String, dynamic>>> readOffers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/acolyte/myoffers.json');
      final contents = await file.readAsString();
      final offers = json.decode(contents) as List;
      return offers.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<File> writeOffers(List<Map<String, dynamic>> offers) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/acolyte/myoffers.json');
    final jsonString = json.encode(offers);
    return file.writeAsString(jsonString);
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.offer != null) {
      // Set the form fields with the offer data
      titleController.text = widget.offer!['title'];
      selectedlocation = widget.offer!['location'];
      priceController.text = widget.offer!['price'];
      whenController.text = widget.offer!['availability'];
      autoTypeController.text = widget.offer!['autoType'];
      vehicleMakeController.text = widget.offer!['vehicleMake'];
      selectedVehicleType = widget.offer!['vehicleType'];
      selectedInstructorExperience = widget.offer!['instructorExperience'];
      selectedEducationLevel = widget.offer!['educationLevel'];
      selectedSkillLevel = widget.offer!['skillLevel'];
      subjectTeachedController.text = widget.offer!['subjectTaught'];
      selectedService = widget.offer!['typeOfService'];
    }

    // Add listeners to text controllers to update form modification status
    titleController.addListener(() => setState(() => isFormModified = true));
    locationController.addListener(() => setState(() => isFormModified = true));
    priceController.addListener(() => setState(() => isFormModified = true));
    whenController.addListener(() => setState(() => isFormModified = true));
    autoTypeController.addListener(() => setState(() => isFormModified = true));
    vehicleMakeController.addListener(() => setState(() => isFormModified = true));
    vehicleTypeController.addListener(() => setState(() => isFormModified = true));
    instructorExperienceController.addListener(() => setState(() => isFormModified = true));
    educationLevelController.addListener(() => setState(() => isFormModified = true));
    skillLevelController.addListener(() => setState(() => isFormModified = true));
    subjectTeachedController.addListener(() => setState(() => isFormModified = true));
  }

  Future<void> _saveOffer() async {
      String selectedbuddyType = '';

      // Determine buddy type based on the selected service
      if (selectedService == 'Driving Lessons') {
        selectedbuddyType = 'Driving Buddy';
      } else if (services.sublist(1).contains(selectedService)) {
        selectedbuddyType = 'Scholar Buddy';
      }

      // Gather form data
      final formData = {
        'title': titleController.text,
        'location': selectedlocation,
        'price': priceController.text,
        'availability': whenController.text,
        'buddyType': selectedbuddyType,
        'typeOfService': selectedService,
        'autoType': autoTypeController.text,
        'vehicleMake': vehicleMakeController.text,
        'vehicleType': selectedVehicleType,
        'instructorExperience': selectedInstructorExperience,
        'educationLevel': selectedEducationLevel,
        'skillLevel': selectedSkillLevel,
        'subjectTaught': subjectTeachedController.text,
      };

      // Get the current Unix timestamp in seconds
      final currentTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();

      // Read the existing offers
      final offers = await readOffers();

      if (widget.isEditing && widget.offer != null) {
        // Update the existing offer
        final existingOffer = widget.offer;
        offers.removeWhere((offer) => offer['uuid'] == existingOffer!['uuid']);
        offers.add({
          'uuid': existingOffer!['uuid'],
          'username': UserData().data['username'],
          'instructor': UserData().data['name'],
          'active': "true",
          ...formData,
          'DateCreation': existingOffer['DateCreation'], // Keep original creation date
          'DateUpdate': currentTimestamp, // Update modification date in Unix format
        });
      } else {
        // Add the new offer with new `uuid`, `DateCreation`, and `DateUpdate` fields
        offers.add({
          'uuid': Utils.generateUUID(),
          'username': UserData().data['username'],
          'instructor': UserData().data['name'],
          'active': "true",
          ...formData,
          'DateCreation': currentTimestamp, // Use current date in Unix format
          'DateUpdate': currentTimestamp, // Same as creation for new offers
        });
      }

      // Write the updated offers to the file
      await writeOffers(offers);

      // Trigger the optional `onSave` callback if provided
      if (widget.onSave != null) {
        widget.onSave!();
      }

      // Close the dialog to exit the form
      Navigator.of(context).pop();
    }
  
  void _resetForm() {
    titleController.clear();
    locationController.clear();
    priceController.clear();
    whenController.clear();
    autoTypeController.clear();
    vehicleMakeController.clear();
    vehicleTypeController.clear();
    instructorExperienceController.clear();
    educationLevelController.clear();
    skillLevelController.clear();
    subjectTeachedController.clear();
    selectedlocation = '-';
    selectedService = '-';
    selectedVehicleType = '-';
    selectedEducationLevel = '-';
    selectedSkillLevel = '-';
    selectedInstructorExperience = '-';
    isFormModified = false;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: [
                      _buildFormRow('Title', titleController),
                      _buildDropdownRow('Type Of Service', services, selectedService, (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            selectedService = newValue;
                            isFormModified = true;
                          }
                        });
                      }),
                      _buildDropdownRow('Location', locations, selectedlocation, (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            selectedlocation = newValue;
                            isFormModified = true;
                          }
                        });
                      }),
                      _buildFormRow('When', whenController),
                      _buildFormRow('Price', priceController, TextInputType.number),
                    ],
                  ),
                ),
                SizedBox(height: 16.0), // Add some spacing between the containers
                if (selectedService == 'Driving Lessons')
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        _buildFormRow('Vehicle Make', vehicleMakeController),
                        _buildDropdownRow('Auto Type', ['Automatic', 'Manual'], autoTypeController.text, (String? newValue) {
                          setState(() {
                            autoTypeController.text = newValue ?? 'Automatic';
                            isFormModified = true;
                          });
                        }),
                        _buildDropdownRow('Vehicle Type', vehicleTypes, selectedVehicleType, (String? newValue) {
                          setState(() {
                            selectedVehicleType = newValue ?? '-';
                            isFormModified = true;
                          });
                        }),
                        _buildDropdownRow("instructor Experience", instructorExperiences, selectedInstructorExperience, (String? newValue) {
                          setState(() {
                            selectedInstructorExperience = newValue ?? '-';
                            isFormModified = true;
                          });
                        }),
                      ],
                    ),
                  )
                else if (services.sublist(1).contains(selectedService))
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        _buildFormRow('Subject Taught', subjectTeachedController),
                        _buildDropdownRow('Education Level', educationLevels, selectedEducationLevel, (String? newValue) {
                          setState(() {
                            selectedEducationLevel = newValue ?? '-';
                            isFormModified = true;
                          });
                        }),
                        _buildDropdownRow('Skill Level', skillLevels, selectedSkillLevel, (String? newValue) {
                          setState(() {
                            selectedSkillLevel = newValue ?? '-';
                            isFormModified = true;
                          });
                        }),
                        _buildDropdownRow("instructor Experience", instructorExperiences, selectedInstructorExperience, (String? newValue) {
                          setState(() {
                            selectedInstructorExperience = newValue ?? '-';
                            isFormModified = true;
                          });
                        }),
                      ],
                    ),
                  ),
                if (isFormModified)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CupertinoButton.filled(
                      child: Text('Save'),
                      onPressed: _saveOffer,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormRow(String label, TextEditingController controller, [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: label,
              keyboardType: keyboardType,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0)),
              ),
              style: TextStyle(color: CupertinoColors.black),
              clearButtonMode: OverlayVisibilityMode.editing,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, List<String> items, String selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(selectedValue),
                  Icon(CupertinoIcons.down_arrow, size: 16),
                ],
              ),
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoActionSheet(
                      actions: items.map((String value) {
                        return CupertinoActionSheetAction(
                          child: Text(value),
                          onPressed: () {
                            Navigator.pop(context);
                            onChanged(value);
                          },
                        );
                      }).toList(),
                      cancelButton: CupertinoActionSheetAction(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

