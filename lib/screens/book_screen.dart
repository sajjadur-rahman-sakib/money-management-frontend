import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashflow/bloc/book_bloc.dart';
import 'package:cashflow/models/book_model.dart';
import 'package:cashflow/services/auth_service.dart';
import 'package:cashflow/services/connectivity_service.dart';
import 'package:cashflow/screens/profile_screen.dart';
import 'package:cashflow/screens/transaction_screen.dart';
import 'package:cashflow/utils/app_snackbar.dart';
import 'package:cashflow/utils/app_urls.dart';

class BookScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const BookScreen({super.key, required this.user});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  Map<String, dynamic>? _cachedUser;
  bool _isOffline = false;
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    context.read<BookBloc>().add(FetchBooksEvent());
    _loadUser();
    _isOffline = !ConnectivityService().isConnected;
    _connectivitySubscription = ConnectivityService().onConnectivityChanged
        .listen((connected) {
          if (mounted) {
            setState(() => _isOffline = !connected);
          }
        });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    _cachedUser = await AuthService().getUser();
    if (mounted) {
      setState(() {});
    }
  }

  void _showCreateBookDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Book'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Book Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<BookBloc>().add(
                  CreateBookEvent(nameController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameBookDialog(String bookId, String currentName) {
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Book'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Book Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<BookBloc>().add(
                  UpdateBookEvent(bookId, nameController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBook(String bookId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<BookBloc>().add(DeleteBookEvent(bookId));
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text(
                "Your Books",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D4379),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<BookBloc, BookState>(
                builder: (context, state) {
                  if (state is BookLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BooksLoaded) {
                    if (state.books.isEmpty) {
                      return const Center(child: Text('No books'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: state.books.length,
                      itemBuilder: (context, index) {
                        Book book = state.books[index];
                        return _buildBookTile(book: book);
                      },
                    );
                  } else if (state is BookError) {
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: Text('No books'));
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _showCreateBookDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9DB2CE),
              foregroundColor: const Color(0xFF1E2D4A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.add, size: 24),
            label: const Text(
              "ADD NEW BOOK",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final userMap = widget.user.isNotEmpty ? widget.user : (_cachedUser ?? {});
    final userName = (userMap['name'] ?? 'User').toString();
    final pic = userMap['picture']?.toString();
    final normalizedPic = pic?.replaceAll('\\', '/');
    final imageUrl = (normalizedPic != null && normalizedPic.isNotEmpty)
        ? (normalizedPic.startsWith('http')
              ? normalizedPic
              : '${AppUrls.baseUrl}/$normalizedPic')
        : null;

    return AppBar(
      backgroundColor: const Color(0xFFF8F9FC),
      elevation: 0,
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(user: widget.user),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9DB2CE),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                border: Border.all(color: const Color(0xFF9DB2CE), width: 2),
              ),
              child: imageUrl == null
                  ? const Icon(Icons.person, color: Color(0xFF1E2D4A), size: 24)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            color: Color(0xFF1E2D4A),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF2D4379),
                      ),
                    ],
                  ),
                  const Text(
                    "Tap to view profile",
                    style: TextStyle(color: Color(0xFF2D4379), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookTile({required Book book}) {
    final bool isPositive = book.balance > 0;
    final String balanceValue = book.balance.abs().toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(
          left: 24,
          right: 16,
          top: 8,
          bottom: 8,
        ),
        leading: Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            color: Color(0xFFE8EDF5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.book, color: Color(0xFF2D4379), size: 24),
        ),
        title: Text(
          book.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2D4A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "Balance: $balanceValue",
            style: const TextStyle(fontSize: 13, color: Color(0xFF2D4379)),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              balanceValue,
              style: TextStyle(
                color: isPositive
                    ? const Color(0xFF2E7D32)
                    : book.balance < 0
                    ? Colors.red
                    : const Color(0xFF2D4379),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF2D4379)),
              onSelected: (value) {
                if (value == 'rename') {
                  _showRenameBookDialog(book.id, book.name);
                } else if (value == 'delete') {
                  _confirmDeleteBook(book.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'rename', child: Text('Rename')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        onTap: () {
          final bookBloc = context.read<BookBloc>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionScreen(bookId: book.id),
            ),
          ).then((_) => bookBloc.add(FetchBooksEvent()));
        },
      ),
    );
  }
}
