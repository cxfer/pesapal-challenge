import 'package:flutter/material.dart';
import 'db_controller.dart';

class ReplScreen extends StatefulWidget {
  const ReplScreen({Key? key}) : super(key: key);

  @override
  State<ReplScreen> createState() => _ReplScreenState();
}

class _ReplScreenState extends State<ReplScreen> {
  final TextEditingController _commandController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DbController _controller = DbController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    _commandController.dispose();
    _scrollController.dispose();
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    // Scroll to bottom when new output is added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _executeCommand() async {
    final command = _commandController.text.trim();
    if (command.isNotEmpty && !_isProcessing) {
      setState(() {
        _isProcessing = true;
      });

      // Show the command with prompt
      _controller.addToOutput('> $command');
      
      try {
        // Execute the actual command
        _controller.executeCommandDirect(command);
      } catch (e) {
        _controller.addToOutput('Error: ${e.toString()}');
      } finally {
        setState(() {
          _isProcessing = false;
        });
        _commandController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[900],
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'pesapal-rdbms Terminal',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Output area
            Expanded(
              child: Container(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount: _controller.outputHistory.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final output = _controller.outputHistory[index];
                        
                        // Check if this is a command prompt (starts with '> ')
                        if (output.startsWith('> ')) {
                          return Text(
                            output,
                            style: const TextStyle(
                              color: Colors.lightBlue,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          );
                        } else if (output.startsWith('Error:')) {
                          return Text(
                            output,
                            style: const TextStyle(
                              color: Colors.red,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          );
                        } else {
                          return Text(
                            output,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            // Input area
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[900],
              child: Row(
                children: [
                  const Text(
                    '> ',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _commandController,
                      onSubmitted: _isProcessing ? null : (_) => _executeCommand(),
                      enabled: !_isProcessing,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                      decoration: InputDecoration(
                        hintText: _isProcessing ? 'Processing...' : 'Enter SQL command...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'monospace',
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _isProcessing ? null : _executeCommand,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _isProcessing ? Icons.hourglass_empty : Icons.arrow_forward_ios,
                      color: _isProcessing ? Colors.grey : Colors.green,
                    ),
                    onPressed: _isProcessing ? null : _executeCommand,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}