import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Report Cortoba',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        ),
      ),
      home: UserInp(),
    );
  }
}

class UserInp extends StatefulWidget {
  @override
  _UserInpState createState() => _UserInpState();
}

class _UserInpState extends State<UserInp> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _inizioTurno;
  bool _partitaIvaChecked = false;
  bool _ea753ndChecked = false;
  bool _cz106vcChecked = false;

  int? _swapEbike;
  int? _fixSwap;
  int? _swapLite;
  int? _relocation;
  int? _repacking;
  int? _shortFix;
  int? _fix;
  int? _swapRelocation;
  int? _fixRelocation;
  int? _fixSwapRelocation;
  int? _pickUp;
  int? _missing;
  int? _deployment;
  double? _oreRicaricaArmadio;
  double? _oreFuoriArea;
  double? _oreAppLenta;
  double? _oreSegnalazioniRitiri;
  String? _kmFurgoneAFineTurno;
  String? _note;

  final List<int> _dropdownValues100 = List.generate(100, (index) => index + 1);
  final List<double> _dropdownValues8 =
      List.generate(16, (index) => (index + 1) * 0.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Cortoba'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildInputCard(
                  context,
                  'DATA INIZIO TURNO',
                  TextFormField(
                    decoration: InputDecoration(labelText: '(Date jj/mm/aaaa)'),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null &&
                          selectedDate != _selectedDate) {
                        setState(() {
                          _selectedDate = selectedDate;
                        });
                      }
                    },
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? "${_selectedDate!.year}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}"
                          : "",
                    ),
                  ),
                ),
                _buildDropdownCard(
                  context,
                  'INIZIO TURNO',
                  _inizioTurno,
                  ['Mattina', 'Pomeriggio', 'Sera'],
                  (value) {
                    setState(() {
                      _inizioTurno = value;
                    });
                  },
                ),
                _buildInputCard(
                  context,
                  'TARGA FURGONE',
                  Row(
                    children: [
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _partitaIvaChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _partitaIvaChecked = value ?? false;
                                    });
                                  },
                                ),
                                Text('DG852CH'),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: _cz106vcChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _cz106vcChecked = value ?? false;
                                    });
                                  },
                                ),
                                Text('CZ106VC'),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: _ea753ndChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _ea753ndChecked = value ?? false;
                                    });
                                  },
                                ),
                                Text('EA753ND'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDropdownCard(
                  context,
                  'SWAP E-BIKE',
                  _swapEbike,
                  _dropdownValues100,
                  (value) {
                    setState(() {
                      _swapEbike = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'SWAP LITE',
                  _swapLite,
                  _dropdownValues100,
                  (value) {
                    setState(() {
                      _swapLite = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'RELOCATION',
                  _relocation,
                  _dropdownValues100,
                  (value) {
                    setState(() {
                      _relocation = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'REPACKING',
                  _repacking,
                  _dropdownValues100,
                  (value) {
                    setState(() {
                      _repacking = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'SHORT FIX',
                  _shortFix,
                  _dropdownValues100,
                  (value) {
                    setState(() {
                      _shortFix = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'FIX',
                  _fix,
                  _dropdownValues100,
                  (value) {
                    setState(() {
                      _fix = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'SWAP + RELOCATION',
                  _swapRelocation,
                  _dropdownValues100,
                  (value) {
                    setState(() {
                      _swapRelocation = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'FIX + SWAP',
                  _fixSwap,
                  _dropdownValues100,
                  (value) {
                    setState(() {
                      _fixSwap = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'FIX + RELOCATION',
                  _fixRelocation,
                  _dropdownValues100,
                  (value) {
                    setState(() {
                      _fixRelocation = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'FIX + SWAP + RELOCATION',
                  _fixSwapRelocation,
                  _dropdownValues100,
                  (value) {
                    setState(() {
                      _fixSwapRelocation = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'PICK UP',
                  _pickUp,
                  _dropdownValues100,
                  (value) {
                    setState(() {
                      _pickUp = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'MISSING',
                  _missing,
                  _dropdownValues100,
                  (value) {
                    setState(() {
                      _missing = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'DEPLOYMENT',
                  _deployment,
                  _dropdownValues100,
                  (value) {
                    setState(() {
                      _deployment = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'ORE RICARICA ARMADIO',
                  _oreRicaricaArmadio,
                  _dropdownValues8,
                  (value) {
                    setState(() {
                      _oreRicaricaArmadio = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'ORE FUORI AREA',
                  _oreFuoriArea,
                  _dropdownValues8,
                  (value) {
                    setState(() {
                      _oreFuoriArea = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'ORE APP LENTA',
                  _oreAppLenta,
                  _dropdownValues8,
                  (value) {
                    setState(() {
                      _oreAppLenta = value;
                    });
                  },
                ),
                _buildDropdownCard(
                  context,
                  'ORE SEGNAZIONI RITIRI',
                  _oreSegnalazioniRitiri,
                  _dropdownValues8,
                  (value) {
                    setState(() {
                      _oreSegnalazioniRitiri = value;
                    });
                  },
                ),
                _buildInputCard(
                  context,
                  'KM FURGONE A FINE TURNO',
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Km'),
                    onChanged: (value) {
                      setState(() {
                        _kmFurgoneAFineTurno = value;
                      });
                    },
                  ),
                ),
                _buildInputCard(
                  context,
                  'NOTE',
                  TextFormField(
                    maxLines: 3,
                    decoration: InputDecoration(labelText: 'Note'),
                    onChanged: (value) {
                      setState(() {
                        _note = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Prepare the data to be sent to the backend
                      final data = {
                        'data_inizio_turno': _selectedDate != null
                            ? "${_selectedDate!.year}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}"
                            : '',
                        'ora_inizio_turno': _selectedTime != null
                            ? "${_selectedTime!.hour}:${_selectedTime!.minute}"
                            : '',
                        'inizio_turno': _inizioTurno,
                        'targa_furgone': _partitaIvaChecked
                            ? 'DG852CH'
                            : _cz106vcChecked
                                ? 'CZ106VC'
                                : _ea753ndChecked
                                    ? 'EA753ND'
                                    : null,
                        'swap_ebike': _swapEbike,
                        'swap_lite': _swapLite,
                        'relocation': _relocation,
                        'repacking': _repacking,
                        'short_fix': _shortFix,
                        'fix': _fix,
                        'swap_relocation': _swapRelocation,
                        'fix_swap': _fixSwap,
                        'fix_relocation': _fixRelocation,
                        'fix_swap_relocation': _fixSwapRelocation,
                        'pick_up': _pickUp,
                        'missing': _missing,
                        'deployment': _deployment,
                        'ore_ricarica_armadio': _oreRicaricaArmadio,
                        'ore_fuori_area': _oreFuoriArea,
                        'ore_app_lenta': _oreAppLenta,
                        'ore_segnalazioni_ritiri': _oreSegnalazioniRitiri,
                        'km_furgone_a_fine_turno': _kmFurgoneAFineTurno,
                        'note': _note,
                      };

                      try {
                        // Retrieve the cookie from SharedPreferences
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? storedCookie = prefs.getString('cookie');

                        // Prepare the body data
                        final bodyData = data.entries
                            .map((e) =>
                                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
                            .join('&'); // Encoding as form-data

                        final response = await http.post(
                          Uri.parse(
                              ' https://intensely-pleasing-bear.ngrok-free.app/testoch/form.php'),
                          headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                            'Accept': 'text/html',
                            // 'Content-Length': contentLength.toString(), // Set only if needed
                            if (storedCookie != null)
                              'Cookie': 'user_auth=$storedCookie;',
                          },
                          body: bodyData, // Include the encoded body data
                        );

                        print('Response status: ${response.statusCode}');
                        print('Response body: ${response.body}');

                        // Handle success response
                        if (response.statusCode == 200) {
                          final jsonResponse = jsonDecode(
                              response.body); // Decode the JSON response

                          if (jsonResponse['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors
                                    .green, // Change background color for success
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color:
                                            Colors.white), // Add success icon
                                    SizedBox(
                                        width:
                                            8), // Space between icon and text
                                    Expanded(
                                      child: Text(
                                        'Data submitted successfully!',
                                        style: TextStyle(
                                            color: Colors
                                                .white), // Change text color
                                      ),
                                    ),
                                  ],
                                ),
                                duration: Duration(
                                    seconds:
                                        3), // Duration for how long it shows
                              ),
                            );
                          } else {
                            // Handle response with unexpected status
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors
                                    .red, // Change background color for error
                                content: Row(
                                  children: [
                                    Icon(Icons.error,
                                        color: Colors.white), // Add error icon
                                    SizedBox(
                                        width:
                                            8), // Space between icon and text
                                    Expanded(
                                      child: Text(
                                        'Error: ${jsonResponse['message'] ?? 'Unknown error'}', // Assuming there's a message field
                                        style: TextStyle(
                                            color: Colors
                                                .white), // Change text color
                                      ),
                                    ),
                                  ],
                                ),
                                duration: Duration(
                                    seconds:
                                        3), // Duration for how long it shows
                              ),
                            );
                          }
                        } else {
                          // Handle non-200 status codes
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors
                                  .red, // Change background color for error
                              content: Row(
                                children: [
                                  Icon(Icons.error,
                                      color: Colors.white), // Add error icon
                                  SizedBox(
                                      width: 8), // Space between icon and text
                                  Expanded(
                                    child: Text(
                                      'Request failed with status: ', // Show status code
                                      style: TextStyle(
                                          color: Colors
                                              .white), // Change text color
                                    ),
                                  ),
                                ],
                              ),
                              duration: Duration(
                                  seconds: 3), // Duration for how long it shows
                            ),
                          );
                        }
                      } catch (e) {
                        // Handle exceptions
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error occurred: $e'),
                            duration: Duration(
                                seconds: 3), // Duration for how long it shows
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
        onTap: (index) {
          if (index == 1) {
            _showLogoutDialog();
          }
        },
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, String title, Widget child) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCard(
      BuildContext context,
      String title,
      dynamic selectedValue,
      List<dynamic> options,
      Function(dynamic) onChanged) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<dynamic>(
              isExpanded: true,
              value: selectedValue,
              onChanged: onChanged,
              items: options.map<DropdownMenuItem<dynamic>>((dynamic value) {
                return DropdownMenuItem<dynamic>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Logout'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
