import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/book_bloc.dart';

class TransactionScreen extends StatefulWidget {
  final String bookId;
  const TransactionScreen({super.key, required this.bookId});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookBloc>().add(FetchBookDetailsEvent(widget.bookId));
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
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
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
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<BookBloc, BookState>(
          builder: (context, state) {
            if (state is BookDetailsLoaded) {
              final data = state.data;
              final book = data['book'];
              return Text('${book['name']} - Balance: ${book['balance']}');
            }
            return Text('Book Details');
          },
        ),
      ),
      body: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          if (state is BookLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is BookDetailsLoaded) {
            final data = state.data;
            final transactions = data['transactions'] as List;
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                var t = transactions[index];
                return ListTile(
                  title: Text(t['description'] ?? 'No description'),
                  subtitle: Text('Amount: ${t['amount']}'),
                );
              },
            );
          } else if (state is BookError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('No transactions'));
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _showTransactionDialog('cash_in'),
            heroTag: 'cash_in',
            child: Icon(Icons.add),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => _showTransactionDialog('cash_out'),
            heroTag: 'cash_out',
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
