import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/bloc/book_bloc.dart';
import 'package:money/models/book_model.dart';
import 'package:money/screens/profile_screen.dart';
import 'package:money/screens/transaction_screen.dart';

class BookScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const BookScreen({super.key, required this.user});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookBloc>().add(FetchBooksEvent());
  }

  void _showCreateBookDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Book'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Book Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
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
            child: Text('Create'),
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
        title: Text('Rename Book'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Book Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
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
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBook(String bookId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Book'),
        content: Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<BookBloc>().add(DeleteBookEvent(bookId));
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: widget.user),
                ),
              );
            },
          ),
          IconButton(icon: Icon(Icons.add), onPressed: _showCreateBookDialog),
        ],
      ),
      body: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          if (state is BookLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is BooksLoaded) {
            return ListView.builder(
              itemCount: state.books.length,
              itemBuilder: (context, index) {
                Book book = state.books[index];
                return ListTile(
                  title: Text(book.name),
                  subtitle: Text('Balance: ${book.balance}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'rename') {
                        _showRenameBookDialog(book.id, book.name);
                      } else if (value == 'delete') {
                        _confirmDeleteBook(book.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  onTap: () {
                    final bookBloc = context.read<BookBloc>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TransactionScreen(bookId: book.id),
                      ),
                    ).then((_) => bookBloc.add(FetchBooksEvent()));
                  },
                );
              },
            );
          } else if (state is BookError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('No books'));
        },
      ),
    );
  }
}
