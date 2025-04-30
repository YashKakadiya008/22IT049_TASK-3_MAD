import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Voice Commands Guide',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCommandSection(
                    context,
                    'Adding Tasks',
                    [
                      '"Add task buy groceries"',
                      '"Create task call mom"',
                      '"New task finish report due tomorrow"',
                      '"Add to do clean the kitchen"',
                    ],
                  ),
                  const Divider(),
                  _buildCommandSection(
                    context,
                    'Adding Tasks with Due Dates',
                    [
                      '"Add task study for exam due tomorrow"',
                      '"Create task project submission due today"',
                      '"New task team meeting due next week"',
                    ],
                  ),
                  const Divider(),
                  _buildCommandSection(
                    context,
                    'Completing Tasks',
                    [
                      '"Complete task buy groceries"',
                      '"Mark task as done call mom"',
                      '"Mark as complete finish report"',
                      '"Finish task clean room"',
                    ],
                  ),
                  const Divider(),
                  _buildCommandSection(
                    context,
                    'Deleting Tasks',
                    [
                      '"Delete task buy groceries"',
                      '"Remove task call mom"',
                    ],
                  ),
                  const Divider(),
                  _buildCommandSection(
                    context,
                    'Updating Tasks',
                    [
                      '"Update task buy groceries to buy milk"',
                      '"Change task call mom to call dad"',
                      '"Modify task deadline to tomorrow"',
                    ],
                  ),
                  const Divider(),
                  _buildCommandSection(
                    context,
                    'Querying Tasks',
                    [
                      '"Show tasks"',
                      '"List tasks"',
                      '"Find tasks today"',
                      '"Search tasks this week"',
                      '"Show to do completed"',
                      '"List tasks tag work"',
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandSection(BuildContext context, String title, List<String> commands) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...commands.map((command) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Text(command),
        )),
        const SizedBox(height: 8),
      ],
    );
  }
} 