import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/core/common/loader.dart';
import 'package:reddit_clone2/features/community/controller/community_controller.dart';

class CreateComminityScreen extends ConsumerStatefulWidget {
  const CreateComminityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateComminityScreenState();
}

class _CreateComminityScreenState extends ConsumerState<CreateComminityScreen> {
  final communityNameController = TextEditingController();

  @override
  void dispose() {
    communityNameController.dispose();
    super.dispose();
  }

  void createCommunity() {
    ref.watch(communityControllerProvider.notifier).createCommunity(communityNameController.text.trim(), context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return isLoading
        ? const Loader()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Create a Community'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Community name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: communityNameController,
                    decoration: const InputDecoration(
                      hintText: 'r/Community_name',
                      filled: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLength: 21,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      createCommunity();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Create Community',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
