import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:CORTOBA/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;
  bool _selectAllColumns = true;
  List<String> _usernames = [];
  String? _selectedUsername;
  // Pagination variables
  int _currentPage = 0;
  final int _itemsPerPage = 6;

  // Filter and sorting states
  String _selectedType = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String _sortColumn = 'id';
  bool _isAscending = true;
  int _currentIndex = 0; // Index for BottomNavigationBar

  // Column visibility states
  Map<String, bool> _columnVisibility = {
    'username': true,
    'data_inizio_turno': true,
    'ora_inizio_turno': true,
    'inizio_turno': true,
    'targa_furgone': true,
    'swap_ebike': true,
    'swap_lite': true,
    'relocation': true,
    'repacking': true,
    'short_fix': true,
    'fix': true,
    'swap_relocation': true,
    'fix_swap': true,
    'fix_relocation': true,
    'fix_swap_relocation': true,
    'pick_up': true,
    'missing': true,
    'deployment': true,
    'ore_ricarica_armadio': true,
    'ore_fuori_area': true,
    'ore_app_lenta': true,
    'ore_segnalazioni_ritiri': true,
    'km_furgone_a_fine_turno': true,
    'note': true,
    'totalPrix': true,
  };

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data from the API when the widget initializes
  }

// Fetch the cookie from SharedPreferences
  Future<String?> _getCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('cookie'); // Retrieve the stored cookie
  }

  // Save the cookie to SharedPreferences
  Future<void> _saveCookie(String cookie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookie', cookie); // Save the cookie
  }

  Future<void> _fetchData() async {
    String? cookie = await _getCookie(); // Retrieve the stored cookie

    final response = await http.get(
      Uri.parse('https://c6eb-41-251-81-69.ngrok-free.app/testoch/admin.php'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'text/html',
        // 'Content-Length': contentLength.toString(), // Set only if needed
        if (cookie != null) 'Cookie': 'user_auth=$cookie;',
      },
    );

    if (response.statusCode == 200) {
      // Save the cookie if it's present in the response headers
      String? setCookie = response.headers['set-cookie'];
      if (setCookie != null) {
        await _saveCookie(setCookie); // Store the cookie for future use
      }

      final List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        _data =
            jsonResponse.map((user) => user as Map<String, dynamic>).toList();
        _isLoading = false;
        _usernames =
            _data.map((user) => user['username'] as String).toSet().toList();
        _usernames.insert(0, 'All'); // Add 'All' option for filtering
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

 @override
Widget build(BuildContext context) {
  // Filtered data based on selected type and date range
  final filteredData = _data.where((row) {
    bool usernameMatches = _selectedUsername == 'All' || row['username'] == _selectedUsername;

    DateTime? dataInizioTurno;
    if (row['data_inizio_turno'] is String) {
      dataInizioTurno = DateTime.tryParse(row['data_inizio_turno']);
    } else if (row['data_inizio_turno'] is DateTime) {
      dataInizioTurno = row['data_inizio_turno'] as DateTime;
    }

    bool dateMatches = _startDate == null ||
        _endDate == null ||
        (dataInizioTurno != null &&
            (dataInizioTurno.isAtSameMomentAs(_startDate!) ||
                dataInizioTurno.isAtSameMomentAs(_endDate!) ||
                (dataInizioTurno.isAfter(_startDate!) && dataInizioTurno.isBefore(_endDate!.add(Duration(days: 1))))));

    return usernameMatches && dateMatches;
  }).toList();

  // Sort data based on selected column
  filteredData.sort((a, b) {
    final aValue = a[_sortColumn];
    final bValue = b[_sortColumn];

    if (aValue is String && bValue is String) {
      return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    } else if (aValue is int && bValue is int) {
      return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    }
    return 0;
  });

  // Paginate data
  final startIndex = _currentPage * _itemsPerPage;
  final endIndex = startIndex + _itemsPerPage;
  final paginatedData = filteredData.sublist(
    startIndex,
    endIndex > filteredData.length ? filteredData.length : endIndex,
  );

  return Scaffold(
    appBar: AppBar(
      title: Text('Admin Dashboard'),
      backgroundColor: Colors.blue,
    ),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchData, // Refresh the data when pulled down
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Filters
                    _buildFilters(),
                    SizedBox(height: 16),
                    // Data Table
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[100]!),
                        columns: _buildDataColumns(),
                        rows: paginatedData.map((row) {
                          return DataRow(
                            cells: _buildDataCells(row),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Display Total Price
                    Text(
                      'Total Price: \€${_calculateGrandTotal(filteredData).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Pagination Controls
                    _buildPaginationControls(filteredData.length),
                  ],
                ),
              ),
            ),
          ),
    bottomNavigationBar: _buildBottomNavigationBar(),
  );
}

  Widget _buildFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen =
            constraints.maxWidth > 600; // Adjust breakpoint as needed

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User Type Dropdown
                    Flexible(
                      child: DropdownButton<String>(
                        value: _selectedUsername,
                        items: _usernames
                            .map((username) => DropdownMenuItem(
                                  value: username,
                                  child: Text(username),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUsername = value!;
                          });
                        },
                        hint: Text('Filter by Username'),
                      ),
                    ),
                    SizedBox(width: 7),
                 
                
                 // Row for Select Columns Popup Menu
                
              
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          if (value == 'Select All') {
                            _selectAllColumns =
                                !_selectAllColumns; // Toggle select all
                            _columnVisibility.updateAll((key, _) =>
                                key != 'totalPrix' ? _selectAllColumns : true);
                          } else {
                            if (value != 'totalPrix') {
                              _columnVisibility[value] = !_columnVisibility[
                                  value]!; // Toggle individual column
                            }
                          }
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'Select All',
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return Row(
                                  children: [
                                    Checkbox(
                                      value: _selectAllColumns,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _selectAllColumns = value ?? false;
                                          _columnVisibility.updateAll(
                                              (key, _) => _selectAllColumns);
                                        });
                                      },
                                    ),
                                    Expanded(child: Text('Select All')),
                                  ],
                                );
                              },
                            ),
                          ),
                          ..._columnVisibility.keys.map((column) {
                            return PopupMenuItem<String>(
                              value: column,
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return Row(
                                    children: [
                                      Checkbox(
                                        value:
                                            _columnVisibility[column] ?? false,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _columnVisibility[column] =
                                                value ?? false;
                                            // Update Select All checkbox based on individual selections
                                            _selectAllColumns =
                                                _columnVisibility.values.every(
                                                    (visible) => visible);
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _columnVisibility[column] =
                                                  !_columnVisibility[column]!;
                                              // Update Select All checkbox based on individual selections
                                              _selectAllColumns =
                                                  _columnVisibility
                                                      .values
                                                      .every(
                                                          (visible) => visible);
                                            });
                                          },
                                          child: Text(column),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ];
                      },
                      
                      child: Container(
                        
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text('Select Columns'),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                

                SizedBox(height: 16),
                // Date fields in a responsive row or column
                isWideScreen
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildDateField('Start Date', (date) {
                              setState(() {
                                _startDate = date;
                                _startDateController.text = date != null
                                    ? date.toLocal().toString().split(' ')[0]
                                    : '';
                              });
                            }),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildDateField('End Date', (date) {
                              setState(() {
                                _endDate = date;
                                _endDateController.text = date != null
                                    ? date.toLocal().toString().split(' ')[0]
                                    : '';
                              });
                            }),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildDateField('Start Date', (date) {
                            setState(() {
                              _startDate = date;
                              _startDateController.text = date != null
                                  ? date.toLocal().toString().split(' ')[0]
                                  : '';
                            });
                          }),
                          SizedBox(height: 10),
                          _buildDateField('End Date', (date) {
                            setState(() {
                              _endDate = date;
                              _endDateController.text = date != null
                                  ? date.toLocal().toString().split(' ')[0]
                                  : '';
                            });
                          }),
                        ],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Widget _buildDateField(String label, Function(DateTime?) onDateSelected) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        final DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        onDateSelected(selectedDate);
      },
      readOnly: true,
      controller:
          label == 'Start Date' ? _startDateController : _endDateController,
    );
  }

  double _calculateTotalPrix(Map<String, dynamic> row) {
    // Define the unit prices as a map
    const unitPrices = {
      'swap_ebike': 1.80,
      'swap_lite': 2.0,
      'relocation': 2.3,
      'repacking': 1.5,
      'short_fix': 2.6,
      'fix': 2.6,
      'swap_relocation': 3.0,
      'fix_swap': 2.8,
      'fix_relocation': 3.0,
      'fix_swap_relocation': 3.2,
      'pick_up': 2.9,
      'missing': 3.0,
      'deployment': 1.7,
      'ore_ricarica_armadio': 16.0,
      'ore_fuori_area': 21.0,
      'ore_app_lenta': 22.0,
      'ore_segnalazioni_ritiri': 21.0,
    };

    double total = 0.0;

    // Loop through the unitPrices to calculate the total
    unitPrices.forEach((key, price) {
      // Only consider the value if the column is visible
      if (_columnVisibility[key] ?? false) {
        var value = row[key];

        // Check if the value is a String and convert to double
        if (value is String) {
          value = double.tryParse(value) ?? 0.0; // Convert or default to 0
        }

        // Only add if the value is a number (int or double)
        if (value is num) {
          total += price * value;
        }
      }
    });

    return total;
  }

// Calculate grand total price for all rows
  double _calculateGrandTotal(List<Map<String, dynamic>> data) {
    double grandTotal = 0.0;
    for (var row in data) {
      grandTotal += _calculateTotalPrix(row);
    }
    return grandTotal;
  }

// Helper function to build a DataCell
  DataCell _buildDataCell(String key, Map<String, dynamic> row) {
    if (_columnVisibility[key] ?? false) {
      // Use ?? to provide default
      return DataCell(Text(row[key]?.toString() ?? '')); // Safely access
    }
    return DataCell(Text(''));
  }


  List<DataColumn> _buildDataColumns() {
    return [
      if ((_columnVisibility['username'] ?? false))
        DataColumn(label: Text('User')),
      if ((_columnVisibility['data_inizio_turno'] ?? false))
        DataColumn(label: Text('Data Inizio Turno')),
      if ((_columnVisibility['inizio_turno'] ?? false))
        DataColumn(label: Text('Inizio Turno')),
      if ((_columnVisibility['targa_furgone'] ?? false))
        DataColumn(label: Text('Targa Furgone')),
      if ((_columnVisibility['swap_ebike'] ?? false))
        DataColumn(label: Text('Swap E-Bike')),
      if ((_columnVisibility['swap_lite'] ?? false))
        DataColumn(label: Text('Swap Lite')),
      if ((_columnVisibility['relocation'] ?? false))
        DataColumn(label: Text('Relocation')),
      if ((_columnVisibility['repacking'] ?? false))
        DataColumn(label: Text('Repacking')),
      if ((_columnVisibility['short_fix'] ?? false))
        DataColumn(label: Text('Short Fix')),
      if ((_columnVisibility['fix'] ?? false)) DataColumn(label: Text('Fix')),
      if ((_columnVisibility['swap_relocation'] ?? false))
        DataColumn(label: Text('Swap Relocation')),
      if ((_columnVisibility['fix_swap'] ?? false))
        DataColumn(label: Text('Fix + Swap')),
      if ((_columnVisibility['fix_relocation'] ?? false))
        DataColumn(label: Text('Fix + Relocation')),
      if ((_columnVisibility['fix_swap_relocation'] ?? false))
        DataColumn(label: Text('Fix + Swap + Relocation')),
      if ((_columnVisibility['pick_up'] ?? false))
        DataColumn(label: Text('Pick Up')),
      if ((_columnVisibility['missing'] ?? false))
        DataColumn(label: Text('Missing')),
      if ((_columnVisibility['deployment'] ?? false))
        DataColumn(label: Text('Deployment')),
      if ((_columnVisibility['ore_ricarica_armadio'] ?? false))
        DataColumn(label: Text('Ore Ricarica Armadio')),
      if ((_columnVisibility['ore_fuori_area'] ?? false))
        DataColumn(label: Text('Ore Fuori Area')),
      if ((_columnVisibility['ore_app_lenta'] ?? false))
        DataColumn(label: Text('Ore App Lenta')),
      if ((_columnVisibility['ore_segnalazioni_ritiri'] ?? false))
        DataColumn(label: Text('Ore Segnalazioni Ritiro')),
      if ((_columnVisibility['km_furgone_a_fine_turno'] ?? false))
        DataColumn(label: Text('KM Furgone a Fine Turno')),
      if ((_columnVisibility['note'] ?? false)) DataColumn(label: Text('Note')),
      if ((_columnVisibility['totalPrix'] ?? false))
        DataColumn(label: Text('Total Price')),
    ];
  }

  List<DataCell> _buildDataCells(Map<String, dynamic> row) {
    return [
      if ((_columnVisibility['username'] ?? false))
        DataCell(Text(row['username']?.toString() ?? '')),
      if ((_columnVisibility['data_inizio_turno'] ?? false))
        DataCell(Text(row['data_inizio_turno']?.toString() ?? '')),
      if ((_columnVisibility['inizio_turno'] ?? false))
        DataCell(Text(row['inizio_turno']?.toString() ?? '')),
      if ((_columnVisibility['targa_furgone'] ?? false))
        DataCell(Text(row['targa_furgone']?.toString() ?? '')),
      if ((_columnVisibility['swap_ebike'] ?? false))
        DataCell(Text(row['swap_ebike']?.toString() ?? '')),
      if ((_columnVisibility['swap_lite'] ?? false))
        DataCell(Text(row['swap_lite']?.toString() ?? '')),
      if ((_columnVisibility['relocation'] ?? false))
        DataCell(Text(row['relocation']?.toString() ?? '')),
      if ((_columnVisibility['repacking'] ?? false))
        DataCell(Text(row['repacking']?.toString() ?? '')),
      if ((_columnVisibility['short_fix'] ?? false))
        DataCell(Text(row['short_fix']?.toString() ?? '')),
      if ((_columnVisibility['fix'] ?? false))
        DataCell(Text(row['fix']?.toString() ?? '')),
      if ((_columnVisibility['swap_relocation'] ?? false))
        DataCell(Text(row['swap_relocation']?.toString() ?? '')),
      if ((_columnVisibility['fix_swap'] ?? false))
        DataCell(Text(row['fix_swap']?.toString() ?? '')),
      if ((_columnVisibility['fix_relocation'] ?? false))
        DataCell(Text(row['fix_relocation']?.toString() ?? '')),
      if ((_columnVisibility['fix_swap_relocation'] ?? false))
        DataCell(Text(row['fix_swap_relocation']?.toString() ?? '')),
      if ((_columnVisibility['pick_up'] ?? false))
        DataCell(Text(row['pick_up']?.toString() ?? '')),
      if ((_columnVisibility['missing'] ?? false))
        DataCell(Text(row['missing']?.toString() ?? '')),
      if ((_columnVisibility['deployment'] ?? false))
        DataCell(Text(row['deployment']?.toString() ?? '')),
      if ((_columnVisibility['ore_ricarica_armadio'] ?? false))
        DataCell(Text(row['ore_ricarica_armadio']?.toString() ?? '')),
      if ((_columnVisibility['ore_fuori_area'] ?? false))
        DataCell(Text(row['ore_fuori_area']?.toString() ?? '')),
      if ((_columnVisibility['ore_app_lenta'] ?? false))
        DataCell(Text(row['ore_app_lenta']?.toString() ?? '')),
      if ((_columnVisibility['ore_segnalazioni_ritiri'] ?? false))
        DataCell(Text(row['ore_segnalazioni_ritiri']?.toString() ?? '')),
      if ((_columnVisibility['km_furgone_a_fine_turno'] ?? false))
        DataCell(Text(row['km_furgone_a_fine_turno']?.toString() ?? '')),
      if ((_columnVisibility['note'] ?? false))
        DataCell(Text(row['note'] ?? '')),
      if ((_columnVisibility['totalPrix'] ?? false))
        DataCell(Text(_calculateTotalPrix(row).toStringAsFixed(2))),
    ];
  }

  Widget _buildPaginationControls(int totalItems) {
    // Calculate total pages and ensure it's at least 1 (to avoid zero page error)
    int totalPages = (totalItems / _itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous Page Button
        IconButton(
          icon: Text(
            '<',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: _currentPage > 0 ? Colors.blue : Colors.grey,
            ),
          ),
          onPressed: _currentPage > 0
              ? () {
                  setState(() {
                    // Decrease current page but make sure it doesn't go below 0
                    if (_currentPage > 0) _currentPage--;
                  });
                }
              : null,
        ),

        // Page Number and Total Pages
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Page ${_currentPage + 1} of $totalPages',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        // Next Page Button
        IconButton(
          icon: Text(
            '>',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: _currentPage < totalPages - 1 ? Colors.blue : Colors.grey,
            ),
          ),
          onPressed: _currentPage < totalPages - 1
              ? () {
                  setState(() {
                    // Increase current page but ensure it doesn't exceed totalPages - 1
                    if (_currentPage < totalPages - 1) _currentPage++;
                  });
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          if (index == 1) {
            _showLogoutDialog();
          }
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Logout'),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
