import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:CORTOBA/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:CORTOBA/pages/home_page copy.dart';
import 'package:CORTOBA/pages/settings_page.dart';

void main() {
  runApp(MyUserApp());
}

class MyUserApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.green,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.green,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyUserPage(),
    );
  }
}

class MyUserPage extends StatefulWidget {
  @override
  _MyUserPageState createState() => _MyUserPageState();
}

class _MyUserPageState extends State<MyUserPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  bool _selectAllColumns = true;
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  // Filter and sorting states
  String _sortColumn = 'id';
  bool _isAscending = true;

  final TextEditingController _searchController = TextEditingController();

  // Column visibility states
  Map<String, bool> _columnVisibility = {
    'id': true,
    'username': true,
    'role': true,
    'created_at': true,
  };

  int _currentIndex = 1; // Default to "User" tab

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Fetch data from the API when the widget initializes
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

  Future<void> _fetchUsers() async {
    String? cookie = await _getCookie(); // Retrieve the stored cookie

    final response = await http.get(
      Uri.parse('https://sculpin-improved-lizard.ngrok-free.app/api/user/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
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
        _users = jsonResponse.map((user) => user as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Sorting logic
  void _sortData(String columnName) {
    setState(() {
      if (_sortColumn == columnName) {
        _isAscending = !_isAscending;
      } else {
        _sortColumn = columnName;
        _isAscending = true;
      }

      _users.sort((a, b) {
        final aValue = a[columnName];
        final bValue = b[columnName];

        if (aValue is String && bValue is String) {
          return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        } else if (aValue is int && bValue is int) {
          return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        } else if (aValue is DateTime && bValue is DateTime) {
          return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        }
        return 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filtered and sorted data based on search
    final filteredData = _users.where((user) {
      return user['username']
              ?.toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ??
          false;
    }).toList();

    // Paginate data
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    final paginatedData = filteredData.sublist(
      startIndex,
      endIndex > filteredData.length ? filteredData.length : endIndex,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchUsers, // Refresh the data when pulled down
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Search and Column Selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Search Field
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                labelText: 'Search by Username',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.search),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _currentPage = 0; // Reset to first page on search
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          // Column Visibility Popup
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              setState(() {
                                if (value == 'Select All') {
                                  _selectAllColumns = !_selectAllColumns;
                                  _columnVisibility.updateAll((key, _) => _selectAllColumns);
                                } else {
                                  _columnVisibility[value] = !_columnVisibility[value]!;
                                  _selectAllColumns = _columnVisibility.values.every((visible) => visible);
                                }
                              });
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem<String>(
                                  value: 'Select All',
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _selectAllColumns,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _selectAllColumns = value ?? false;
                                            _columnVisibility.updateAll((key, _) => _selectAllColumns);
                                          });
                                        },
                                      ),
                                      Text('Select All'),
                                    ],
                                  ),
                                ),
                                ..._columnVisibility.keys.map((column) {
                                  return PopupMenuItem<String>(
                                    value: column,
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: _columnVisibility[column],
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _columnVisibility[column] = value ?? false;
                                              _selectAllColumns = _columnVisibility.values.every((visible) => visible);
                                            });
                                          },
                                        ),
                                        Text(column.toUpperCase()),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ];
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Columns'),
                                  Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Data Table
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          sortAscending: _isAscending,
                          sortColumnIndex: _getSortColumnIndex(),
                          columns: _buildDataColumns(),
                          rows: paginatedData.map((user) {
                            return DataRow(
                              cells: _buildDataCells(user),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 20),
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

  // Get the index of the sort column for DataTable
  int? _getSortColumnIndex() {
    switch (_sortColumn) {
      case 'id':
        return 0;
      case 'username':
        return 1;
      case 'role':
        return 2;
      case 'created_at':
        return 3;
      default:
        return null;
    }
  }

  List<DataColumn> _buildDataColumns() {
    return [
      if ((_columnVisibility['id'] ?? false))
        DataColumn(
          label: Text('ID'),
          onSort: (columnIndex, _) {
            _sortData('id');
          },
        ),
      if ((_columnVisibility['username'] ?? false))
        DataColumn(
          label: Text('Username'),
          onSort: (columnIndex, _) {
            _sortData('username');
          },
        ),
      if ((_columnVisibility['role'] ?? false))
        DataColumn(
          label: Text('Role'),
          onSort: (columnIndex, _) {
            _sortData('role');
          },
        ),
      if ((_columnVisibility['created_at'] ?? false))
        DataColumn(
          label: Text('Created At'),
          onSort: (columnIndex, _) {
            _sortData('created_at');
          },
        ),
      DataColumn(label: Text('Actions')),
    ];
  }

  List<DataCell> _buildDataCells(Map<String, dynamic> user) {
    return [
      if ((_columnVisibility['id'] ?? false))
        DataCell(Text(user['id'].toString())),
      if ((_columnVisibility['username'] ?? false))
        DataCell(Text(user['username'] ?? '')),
      if ((_columnVisibility['role'] ?? false))
        DataCell(Text(user['role'] ?? '')),
      if ((_columnVisibility['created_at'] ?? false))
        DataCell(Text(user['created_at'] ?? '')),
      DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editUser(user),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteUser(user),
            ),
          ],
        ),
      ),
    ];
  }

  void _deleteUser(Map<String, dynamic> user) async {
    // Show a confirmation dialog before deleting
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete user "${user['username']}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // Remove the user from the list
      setState(() {
        _users.removeWhere((u) => u['id'] == user['id']);
      });

      // Optionally, send a request to your backend to delete the user from the database
      await _deleteUserFromBackend(user);
    }
  }

  Future<void> _deleteUserFromBackend(Map<String, dynamic> user) async {
    String? cookie = await _getCookie(); // Retrieve the stored cookie

    final response = await http.get(
      Uri.parse('https://sculpin-improved-lizard.ngrok-free.app/api/user/delete/${user['id']}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (cookie != null) 'Cookie': 'user_auth=$cookie;',
      },
    );

    if (response.statusCode != 200) {
      // Handle the error accordingly
        String? setCookie = response.headers['set-cookie'];
      if (setCookie != null) {
        await _saveCookie(setCookie); // Store the cookie for future use
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user')),
      );
    }
  }

  Future<void> _editUser(Map<String, dynamic> user) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _usernameController =
        TextEditingController(text: user['username']);
    final TextEditingController _roleController =
        TextEditingController(text: user['role']);
    final TextEditingController _passwordController =
        TextEditingController(); // New controller for password

    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  // Role Field
                  TextFormField(
                    controller: _roleController,
                    decoration: InputDecoration(labelText: 'Role'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a role';
                      }
                      return null;
                    },
                  ),
                  // Password Field (New)
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true, // Hide the password input
                    validator: (value) {
                      // Password can be optional; validate only if not empty
                      if (value != null && value.isNotEmpty && value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _updateUser(
        user['id'],
        _usernameController.text,
        _roleController.text,
        _passwordController.text, // Pass the password
      );
    }
  }

  Future<void> _updateUser(int id, String newUsername, String newRole, String newPassword) async {
    String? cookie = await _getCookie();

    // Prepare the request body
    Map<String, dynamic> requestBody = {
      'username': newUsername,
      'role': newRole,
    };

    // Include password only if it's not empty
    if (newPassword.isNotEmpty) {
      requestBody['password'] = newPassword;
    }

    final response = await http.post(
      Uri.parse('https://sculpin-improved-lizard.ngrok-free.app/api/user/update/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (cookie != null) 'Cookie': 'user_auth=$cookie;',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      // Handle response data
      
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User updated successfully')),
        );
        _fetchUsers(); // Refresh the user list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'] ?? 'Failed to update user')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user')),
      );
    }
  }

  Widget _buildPaginationControls(int totalItems) {
    int totalPages = (totalItems / _itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous Page Button
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _currentPage > 0
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
        ),
        // Page Number and Total Pages
        Text(
          'Page ${_currentPage + 1} of $totalPages',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        // Next Page Button
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: _currentPage < totalPages - 1
              ? () {
                  setState(() {
                    _currentPage++;
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
          if (index == 3) {
            _showLogoutDialog();
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyUserPage()),
            );
          } else if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage1()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          }
        });
      },
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      selectedItemColor: const Color.fromARGB(255, 49, 136, 163),
      unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'rapports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'User',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Setting',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.exit_to_app),
          label: 'Logout',
        ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}