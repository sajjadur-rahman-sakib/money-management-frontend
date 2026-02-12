import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money/services/connectivity_service.dart';
import 'package:money/utils/app_snackbar.dart';
import '../bloc/book_bloc.dart';

class TransactionScreen extends StatefulWidget {
  final String bookId;
  const TransactionScreen({super.key, required this.bookId});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  bool _isOffline = false;
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    context.read<BookBloc>().add(FetchBookDetailsEvent(widget.bookId));
    _isOffline = !ConnectivityService().isConnected;
    _connectivitySubscription = ConnectivityService().onConnectivityChanged
        .listen((connected) {
          if (mounted) {
            setState(() => _isOffline = !connected);
            if (connected) {
              context.read<BookBloc>().add(
                FetchBookDetailsEvent(widget.bookId),
              );
            }
          }
        });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _showTransactionDialog(String type) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 'cash_in' ? 'Cash In' : 'Cash Out'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              double? amount = double.tryParse(amountController.text);
              if (amount != null) {
                context.read<BookBloc>().add(
                  CreateTransactionEvent(
                    widget.bookId,
                    type,
                    amount,
                    descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showRenameTransactionDialog(
    String transactionId,
    double currentAmount,
    String? currentDescription,
  ) {
    final amountController = TextEditingController(
      text: currentAmount.toString(),
    );
    final descriptionController = TextEditingController(
      text: currentDescription ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                return;
              }
              context.read<BookBloc>().add(
                UpdateTransactionEvent(
                  widget.bookId,
                  transactionId,
                  amount,
                  descriptionController.text,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTransaction(String transactionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<BookBloc>().add(
                DeleteTransactionEvent(widget.bookId, transactionId),
              );
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: _buildAppBar(),
      body: BlocListener<BookBloc, BookState>(
        listener: (context, state) {
          if (state is BookOfflineSuccess) {
            AppSnackbar.showWarning(context, state.message);
          }
        },
        child: Column(
          children: [
            if (_isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                color: const Color(0xFFF57C00),
                child: const Text(
                  'You are offline. Changes will sync when connected.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Expanded(
              child: BlocBuilder<BookBloc, BookState>(
                builder: (context, state) {
                  if (state is BookLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BookDetailsLoaded) {
                    final data = state.data;
                    final book = data['book'] ?? {};
                    final transactions = data['transactions'] as List;
                    final balance =
                        (book['balance'] as num?)?.toDouble() ?? 0.0;
                    final totalIn = _calculateTotalIn(transactions);
                    final totalOut = _calculateTotalOut(transactions);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 100,
                              ),
                              children: [
                                _buildSummaryCard(balance, totalIn, totalOut),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Showing ${transactions.length} entries",
                                      style: const TextStyle(
                                        color: Color(0xFF2D4379),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                ..._buildTransactionList(transactions),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is BookError) {
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: Text('No transactions'));
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  double _calculateTotalIn(List transactions) {
    double total = 0;
    for (var t in transactions) {
      if (t['type'] == 'cash_in') {
        total += (t['amount'] as num).toDouble();
      }
    }
    return total;
  }

  double _calculateTotalOut(List transactions) {
    double total = 0;
    for (var t in transactions) {
      if (t['type'] == 'cash_out') {
        total += (t['amount'] as num).toDouble();
      }
    }
    return total;
  }

  List<Widget> _buildTransactionList(List transactions) {
    if (transactions.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No transactions yet')),
        ),
      ];
    }

    Map<String, List<dynamic>> grouped = {};
    for (var t in transactions) {
      String dateKey;
      if (t['created_at'] != null) {
        final date = DateTime.parse(t['created_at']);
        dateKey = DateFormat('dd MMMM yyyy').format(date);
      } else {
        dateKey = 'Unknown Date';
      }
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(t);
    }

    List<Widget> widgets = [];
    grouped.forEach((date, items) {
      widgets.add(_buildDateHeader(date));
      for (var t in items) {
        widgets.add(_buildTransactionItem(t));
      }
    });

    return widgets;
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FC),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Color(0xFF1E2D4A),
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          String bookName = 'Book Details';
          double balance = 0;
          if (state is BookDetailsLoaded) {
            bookName = state.data['book']?['name'] ?? 'Book Details';
            balance =
                (state.data['book']?['balance'] as num?)?.toDouble() ?? 0.0;
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bookName,
                style: const TextStyle(
                  color: Color(0xFF1E2D4A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 50),
              Text(
                balance.toStringAsFixed(0),
                style: TextStyle(
                  color: balance >= 0
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(double balance, double totalIn, double totalOut) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Net Balance",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E2D4A),
                ),
              ),
              Text(
                balance.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2D4A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total In (+)",
                style: TextStyle(color: Color(0xFF1E2D4A)),
              ),
              Text(
                totalIn.toStringAsFixed(0),
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Out (-)",
                style: TextStyle(color: Color(0xFF1E2D4A)),
              ),
              Text(
                totalOut.toStringAsFixed(0),
                style: const TextStyle(
                  color: Color(0xFFC62828),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFE8EDF5),
      child: Text(
        date,
        style: const TextStyle(
          color: Color(0xFF2D4379),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(dynamic t) {
    final isExpense = t['type'] == 'cash_out';
    final amount = (t['amount'] as num).toDouble();
    final description = t['description'] ?? 'No description';
    final transactionId = t['id'].toString();

    String timeString = '';
    final now = DateTime.now();
    timeString = 'Entry at ${DateFormat('h:mm a').format(now)}';

    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _showRenameTransactionDialog(
                      transactionId,
                      amount,
                      t['description'],
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteTransaction(transactionId);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EDF5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isExpense ? 'Cash Out' : 'Cash In',
                      style: TextStyle(
                        color: const Color(0xFF2D4379),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E2D4A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeString,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Text(
              amount.toStringAsFixed(0),
              style: TextStyle(
                color: isExpense
                    ? const Color(0xFFC62828)
                    : const Color(0xFF2E7D32),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey.shade400,
                size: 20,
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  _showRenameTransactionDialog(
                    transactionId,
                    amount,
                    t['description'],
                  );
                } else if (value == 'delete') {
                  _confirmDeleteTransaction(transactionId);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 70,
      elevation: 10,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showTransactionDialog('cash_in'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                "CASH IN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showTransactionDialog('cash_out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.remove, size: 18),
              label: const Text(
                "CASH OUT",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
