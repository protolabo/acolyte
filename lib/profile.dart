import 'package:flutter/material.dart';
import 'userData.dart';

class RedProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Utils.buildInternalPageContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(child: ProfilePage(textColor: const Color.fromARGB(255, 244, 185, 181), boolMode: 0)),
        ],
      ),
    );
  }
}

class BlueProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Utils.buildInternalPageContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(child: ProfilePage(textColor: Color.fromARGB(255, 171, 205, 235), boolMode: 1)),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final Color textColor;
  final int boolMode;

  const ProfilePage({Key? key, required this.textColor, required this.boolMode}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  String selectedCountry = 'Canada';
  bool isModified = false;
  final List<String> countries = ["United States", "Canada", "Morocco", "Japan"];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    var userData = UserData().data;
    nameController.text = userData['name'] ?? '';
    lastNameController.text = userData['lastName'] ?? '';
    usernameController.text = userData['username'] ?? '';
    phoneController.text = userData['phone'] ?? '';
    emailController.text = userData['email'] ?? '';
    passwordController.text = userData['password'] ?? '';
    dobController.text = userData['dob'] ?? '';
    selectedCountry = userData['country'] ?? 'Canada';
  }

  void _saveUserData() async {
    if (_validateInputs()) {
      UserData().data = {
        'name': nameController.text,
        'lastName': lastNameController.text,
        'username': usernameController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'dob': dobController.text,
        'country': selectedCountry,
      };
      await UserData().saveData();
      setState(() => isModified = false);
    }
  }

  bool _validateInputs() {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailController.text);
    bool phoneValid = RegExp(r"^\+?([0-9]{1,3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{3})[-. ]?([0-9]{4})$").hasMatch(phoneController.text);
    if (!emailValid || !phoneValid || nameController.text.isEmpty || usernameController.text.isEmpty || phoneController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty || dobController.text.isEmpty || selectedCountry.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Validation Error'),
          content: Text('Please fill in all fields correctly.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Utils.buildInternalPageContainer(_profileContent()),
      ),
    );
  }

  Widget _profileContent() {
    return Column(
      children: [
        _buildTextField(nameController, 'Full Name', false),
        _buildTextField(usernameController, 'Username', false),
        _buildTextField(phoneController, 'Phone Number', false),
        _buildTextField(emailController, 'Email', false),
        _buildTextField(passwordController, 'Password', true),
        _buildDateField(),
        _buildDropdownField(),
        SizedBox(height: 20),
        Visibility(
          visible: isModified,
          child: ElevatedButton(
            onPressed: _saveUserData,
            child: Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.textColor,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool obscure) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: obscure,
      onChanged: (_) => setState(() => isModified = true),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
          setState(() => isModified = true);
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: dobController,
          decoration: InputDecoration(labelText: 'Date of Birth'),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: selectedCountry,
      onChanged: (newValue) {
        setState(() {
          selectedCountry = newValue!;
          isModified = true;
        });
      },
      items: countries.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(labelText: 'Country/Region'),
    );
  }
}